"""Six-module portfolio prototype. Python 3 standard library; no credentials.
Run: python pipeline.py. Synthetic fixtures are generated only by --demo.
"""
import argparse, csv, json, math, random, sqlite3
from pathlib import Path
from datetime import date, datetime, timedelta
from collections import defaultdict
from statistics import mean

ROOT=Path(__file__).resolve().parent
def read(name):
    with (ROOT/'inputs'/f'{name}.csv').open(newline='') as f: return list(csv.DictReader(f))
def write(folder,name,rows):
    p=ROOT/folder/f'{name}.csv'; p.parent.mkdir(parents=True,exist_ok=True)
    if not rows: raise ValueError(f'Empty output: {name}')
    with p.open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
def demo():
    rng=random.Random(570);start=date(2025,1,1)
    products=[{'ProductID':1,'Product':'Rice 1kg','Price':80,'Cost':55,'SupplierID':'S1','LeadDays':2,'MOQ':24,'PackSize':12},
              {'ProductID':2,'Product':'Tea 250g','Price':140,'Cost':90,'SupplierID':'S2','LeadDays':3,'MOQ':20,'PackSize':10},
              {'ProductID':3,'Product':'Lentils 1kg','Price':150,'Cost':105,'SupplierID':'S1','LeadDays':2,'MOQ':24,'PackSize':12}]
    stores=[{'StoreID':i,'Store':c,'UnitsPerHour':30,'FixedHours':4,'MinStaff':2,'OpenHours':8,'HourlyRate':180} for i,c in enumerate(['Pune','Hyderabad','Bengaluru'],1)]
    sales=[]
    for n in range(365):
        d=start+timedelta(days=n)
        for s in stores:
            for p in products:
                u=round((110+10*s['StoreID'])*(1.35 if d.weekday()>=5 else 1)*(1+n*.0005)*rng.uniform(.88,1.12))
                sales.append({'Date':str(d),'StoreID':s['StoreID'],'ProductID':p['ProductID'],'Units':u,'Sales':round(u*p['Price'],2)})
    employees=[];availability=[]
    for s in stores:
        for n in range(1,5):
            eid=f"E{s['StoreID']}{n}"
            employees.append({'EmployeeID':eid,'StoreID':s['StoreID'],'Role':'Associate','HourlyRate':180+n*5,'MaxWeeklyHours':40})
            for wd in range(7):availability.append({'EmployeeID':eid,'Weekday':wd,'Available':int((n+wd)%7!=0)})
    inventory=[{'AsOfDate':'2025-12-31','StoreID':s['StoreID'],'ProductID':p['ProductID'],'OnHand':250,'OnOrder':0} for s in stores for p in products]
    for name,rows in [('sales',sales),('stores',stores),('products',products),('employees',employees),('availability',availability),('inventory',inventory)]:write('inputs',name,rows)

def forecast(history,origin,days=7):
    """Trailing four same-weekday mean, trained strictly before origin."""
    grouped=defaultdict(list)
    for r in history:
        d=date.fromisoformat(r['Date'])
        if d<origin: grouped[(int(r['StoreID']),int(r['ProductID']),d.weekday())].append((d,float(r['Units'])))
    out=[]
    keys=sorted({(int(r['StoreID']),int(r['ProductID'])) for r in history if date.fromisoformat(r['Date'])<origin})
    for offset in range(days):
        d=origin+timedelta(days=offset)
        for s,p in keys:
            values=sorted(grouped[(s,p,d.weekday())])[-4:]
            if len(values)<4: raise ValueError('At least four prior observations per weekday are required')
            out.append({'Date':str(d),'StoreID':s,'ProductID':p,'ForecastUnits':round(mean(x[1] for x in values),2),'Origin':str(origin),'Model':'same_weekday_4_mean'})
    return out

def run():
    sales=read('sales'); stores={int(r['StoreID']):r for r in read('stores')}; products={int(r['ProductID']):r for r in read('products')}
    employees=read('employees'); inventory=read('inventory'); availability={(r['EmployeeID'],int(r['Weekday'])):int(r['Available']) for r in read('availability')}
    # Fail early rather than silently fill missing data or duplicate fact keys.
    keys=[(r['Date'],r['StoreID'],r['ProductID']) for r in sales]
    assert len(keys)==len(set(keys)), 'Duplicate sales grain'
    assert all(float(r['Units'])>=0 and int(r['StoreID']) in stores and int(r['ProductID']) in products for r in sales)
    latest=max(date.fromisoformat(r['Date']) for r in sales); origin=latest+timedelta(days=1)
    for s in stores:
        for p in products:
            ds={date.fromisoformat(r['Date']) for r in sales if int(r['StoreID'])==s and int(r['ProductID'])==p}
            assert all(latest-timedelta(days=i) in ds for i in range(56)), 'Missing sales in training/evaluation window'
    assert all(date.fromisoformat(r['AsOfDate'])==latest for r in inventory),'Inventory snapshot must match latest sales date'
    predictions=forecast(sales,origin)
    for r in predictions:r['ForecastSales']=round(r['ForecastUnits']*float(products[r['ProductID']]['Price']),2)
    # Four non-overlapping seven-day holdouts; no future values used by each origin.
    actual={(r['Date'],int(r['StoreID']),int(r['ProductID'])):r for r in sales}; backtest=[]
    for lag in [28,21,14,7]:
        cut=origin-timedelta(days=lag)
        for r in forecast(sales,cut):
            a=actual[(r['Date'],r['StoreID'],r['ProductID'])]; lastweek=actual[(str(date.fromisoformat(r['Date'])-timedelta(days=7)),r['StoreID'],r['ProductID'])]
            v=float(a['Units']);f=r['ForecastUnits'];base=float(lastweek['Units'])
            backtest.append({**r,'ActualUnits':v,'ActualSales':float(a['Sales']),'AbsoluteError':round(abs(v-f),2),'SquaredError':round((v-f)**2,4),'BaselineUnits':base,'BaselineAbsoluteError':abs(v-base),'BiasUnits':round(f-v,2)})
    totals=defaultdict(float)
    for r in predictions:totals[(r['Date'],r['StoreID'])]+=r['ForecastUnits']
    labor=[]
    for (d,s),units in sorted(totals.items()):
        rule=stores[s];variable=units/float(rule['UnitsPerHour']);fixed=float(rule['FixedHours']);floor=float(rule['MinStaff'])*float(rule['OpenHours'])
        hours=max(variable+fixed,floor)
        labor.append({'Date':d,'StoreID':s,'ForecastUnits':round(units,2),'VariableHours':round(variable,2),'FixedHours':fixed,'RequiredHours':round(hours,2),'ForecastLaborCost':round(hours*float(rule['HourlyRate']),2)})
    purchases=[]
    for r in inventory:
        s=int(r['StoreID']);p=int(r['ProductID']);policy=products[p];lead=int(policy['LeadDays']);review=2;safety=2;horizon=lead+review+safety
        assert horizon<=7,'Increase forecast horizon to cover lead + review + safety'
        demand=[x['ForecastUnits'] for x in predictions if x['StoreID']==s and x['ProductID']==p]
        daily=mean(demand);position=float(r['OnHand'])+float(r['OnOrder']);target=daily*horizon
        shortage=max(0,target-position);pack=int(policy['PackSize']);moq=int(policy['MOQ'])
        order=math.ceil(max(shortage,moq)/pack)*pack if shortage>0 else 0
        purchases.append({'AsOfDate':str(latest),'StoreID':s,'ProductID':p,'SupplierID':policy['SupplierID'],'OnHand':float(r['OnHand']),'InventoryPosition':position,'DailyDemand':round(daily,2),'ReorderPoint':round(daily*(lead+safety),2),'TargetStock':round(target,2),'OrderUnits':order,'OrderCost':round(order*float(policy['Cost']),2),'RecommendedOrderDate':str(origin),'ExpectedArrivalDate':str(origin+timedelta(days=lead)),'StockoutBeforeArrival':int(float(r['OnHand'])<daily*lead)})
    # Greedy whole-day allocation. Each assignment is 09:00–17:00; no claim of optimization.
    used=defaultdict(float);schedule=[];coverage=[]
    for r in labor:
        d=date.fromisoformat(r['Date']);s=r['StoreID'];week=d.isocalendar()[:2];need=math.ceil(r['RequiredHours']/8);assigned=0
        candidates=sorted([e for e in employees if int(e['StoreID'])==s and e['Role']=='Associate'],key=lambda e:(used[(e['EmployeeID'],week)],e['EmployeeID']))
        for e in candidates:
            eid=e['EmployeeID']
            if assigned>=need:break
            if not availability.get((eid,d.weekday()),0) or used[(eid,week)]+8>float(e['MaxWeeklyHours']):continue
            schedule.append({'Date':str(d),'StoreID':s,'EmployeeID':eid,'Role':e['Role'],'Start':f'{d}T09:00:00','End':f'{d}T17:00:00','ScheduledPaidHours':8,'Status':'DRAFT'})
            used[(eid,week)]+=8;assigned+=1
        coverage.append({'Date':str(d),'StoreID':s,'RequiredHours':r['RequiredHours'],'ScheduledHours':assigned*8,'UnfilledHours':round(max(0,r['RequiredHours']-assigned*8),2),'ExcessHours':round(max(0,assigned*8-r['RequiredHours']),2)})
    # Input is an explicit independent timecard file. No automatic manager approval.
    if not (ROOT/'inputs/timecards.csv').exists():raise ValueError('Supply timecards.csv, or run --demo to generate illustrative timecards')
    timecards=read('timecards');emp={e['EmployeeID']:e for e in employees}; seen=set();validated=[];pay=[]
    for t in timecards:
        errors=[];eid=t['EmployeeID'];key=(t['Date'],eid)
        if key in seen:errors.append('duplicate')
        seen.add(key)
        if eid not in emp:errors.append('unknown_employee')
        hours=0
        try:
            start=datetime.fromisoformat(t['ClockIn']);end=datetime.fromisoformat(t['ClockOut']);hours=(end-start).total_seconds()/3600-float(t['UnpaidBreakMinutes'])/60
            if start.date()!=date.fromisoformat(t['Date']) or hours<=0 or hours>16 or float(t['UnpaidBreakMinutes'])<0:errors.append('invalid_duration')
        except (ValueError,TypeError):errors.append('invalid_timestamp')
        matches=[x for x in schedule if x['Date']==t['Date'] and x['EmployeeID']==eid]
        if not matches:errors.append('no_draft_schedule')
        if matches and abs(hours-float(matches[0]['ScheduledPaidHours']))>1:errors.append('schedule_variance')
        if t['ApprovalStatus']!='APPROVED' or not t['ApprovedBy'].strip():errors.append('unapproved')
        validated.append({**t,'StoreID':int(emp[eid]['StoreID']) if eid in emp else -1,'PaidHours':round(hours,2),'EligibleForPay':int(not errors),'Exceptions':'|'.join(errors)})
    # Reject EVERY occurrence of a duplicated timecard key, not just later ones.
    counts=defaultdict(int)
    for t in timecards:counts[(t['Date'],t['EmployeeID'])]+=1
    paidweek=defaultdict(float)
    for t in sorted(validated,key=lambda x:(x['Date'],x['EmployeeID'])):
        if counts[(t['Date'],t['EmployeeID'])]>1:
            t['EligibleForPay']=0
            if 'duplicate' not in t['Exceptions'].split('|'):t['Exceptions']+='|duplicate'
        if not t['EligibleForPay']:continue
        e=emp[t['EmployeeID']];key=(t['EmployeeID'],date.fromisoformat(t['Date']).isocalendar()[:2]);h=t['PaidHours']
        regular=min(h,max(0,40-paidweek[key]));ot=h-regular;paidweek[key]+=h;rate=float(e['HourlyRate'])
        pay.append({'Date':t['Date'],'EmployeeID':t['EmployeeID'],'StoreID':int(e['StoreID']),'RegularHours':round(regular,2),'OvertimeHours':round(ot,2),'RegularPay':round(regular*rate,2),'OvertimePay':round(ot*rate*1.5,2),'IllustrativeGrossPay':round(regular*rate+ot*rate*1.5,2)})
    outputs={'FactForecast':predictions,'FactBacktest':backtest,'FactLaborForecast':labor,'FactPurchasing':purchases,'FactSchedule':schedule,'FactCoverage':coverage,'FactTimekeeping':validated,'FactPay':pay,
             'DimStore':list(stores.values()),'DimProduct':list(products.values()),'DimEmployee':employees}
    first=min(date.fromisoformat(r['Date']) for r in sales);last=origin+timedelta(days=6)
    outputs['DimDate']=[{'Date':str(first+timedelta(days=n)),'Month':(first+timedelta(days=n)).strftime('%Y-%m')} for n in range((last-first).days+1)]
    db=sqlite3.connect(ROOT/'operations.sqlite')
    for name,rows in outputs.items():
        db.execute(f'DROP TABLE IF EXISTS {name}')
        if not rows:
            (ROOT/'outputs'/f'{name}.csv').unlink(missing_ok=True)
            continue
        write('outputs',name,rows); cols=list(rows[0])
        db.execute(f'CREATE TABLE {name} ('+','.join(f'"{k}" '+('REAL' if isinstance(rows[0][k],(int,float)) else 'TEXT') for k in cols)+')')
        db.executemany(f'INSERT INTO {name} VALUES ('+','.join('?' for _ in cols)+')',[tuple(r.values()) for r in rows])
    db.commit();db.close()
    report={'origin':str(origin),'data':'synthetic' if args.demo else 'user-supplied; verify provenance','forecast_rows':len(predictions),'backtest_rows':len(backtest),'WAPE':sum(r['AbsoluteError'] for r in backtest)/sum(r['ActualUnits'] for r in backtest),'BaselineWAPE':sum(r['BaselineAbsoluteError'] for r in backtest)/sum(r['ActualUnits'] for r in backtest),'MAE':mean(r['AbsoluteError'] for r in backtest),'RMSE':math.sqrt(mean(r['SquaredError'] for r in backtest)),'unfilled_hours':round(sum(r['UnfilledHours'] for r in coverage),2),'timecards_blocked':sum(not r['EligibleForPay'] for r in validated),'pay_rows':len(pay),'illustrative_gross_pay':round(sum(r['IllustrativeGrossPay'] for r in pay),2)}
    (ROOT/'outputs/run-summary.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--demo',action='store_true',help='Overwrite input fixtures with synthetic data');args=parser.parse_args()
    if args.demo:
        demo()
        # Independent illustrative punches and approvals; entirely fictional.
        cards=[]
        for day in range(7):
            d=date(2026,1,1)+timedelta(days=day)
            for e in read('employees'):
                if (int(e['EmployeeID'][-1])+d.weekday())%7==0:continue
                cards.append({'Date':str(d),'EmployeeID':e['EmployeeID'],'ClockIn':f'{d}T09:00:00','ClockOut':f'{d}T17:00:00','UnpaidBreakMinutes':0,'ApprovalStatus':'APPROVED','ApprovedBy':'DEMO_MANAGER'})
        cards[0]['ClockOut']='';cards[1]['ApprovalStatus']='PENDING'
        write('inputs','timecards',cards)
    run()
