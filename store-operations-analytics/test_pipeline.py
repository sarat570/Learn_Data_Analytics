"""Run with python -m unittest -v. Tests isolated copies, never original inputs."""
import unittest, tempfile, shutil, csv, subprocess, sys, json
from pathlib import Path
import pipeline

class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        shutil.copy(Path(__file__).with_name('pipeline.py'),self.root/'pipeline.py')
        self.run_pipeline('--demo')
    def tearDown(self):self.tmp.cleanup()
    def run_pipeline(self,*args,success=True):
        r=subprocess.run([sys.executable,str(self.root/'pipeline.py'),*args],capture_output=True,text=True)
        if success:self.assertEqual(r.returncode,0,r.stderr)
        else:self.assertNotEqual(r.returncode,0)
        return r
    def rows(self,name,folder='outputs'):
        with (self.root/folder/f'{name}.csv').open() as f:return list(csv.DictReader(f))
    def replace(self,name,rows):
        with (self.root/'inputs'/f'{name}.csv').open('w',newline='') as f:
            w=csv.DictWriter(f,fieldnames=rows[0]);w.writeheader();w.writerows(rows)
    def test_forecast_has_no_future_leakage(self):
        history=self.rows('sales','inputs');cut=pipeline.date(2025,12,4)
        before=pipeline.forecast(history,cut)
        for r in history:
            if r['Date']>=str(cut):r['Units']='999999'
        self.assertEqual(before,pipeline.forecast(history,cut))
    def test_schedule_respects_availability_and_weekly_cap(self):
        avail={(r['EmployeeID'],int(r['Weekday'])):int(r['Available']) for r in self.rows('availability','inputs')};hours={}
        for r in self.rows('FactSchedule'):
            day=pipeline.date.fromisoformat(r['Date']);key=(r['EmployeeID'],day.isocalendar()[:2])
            self.assertEqual(avail[(r['EmployeeID'],day.weekday())],1)
            hours[key]=hours.get(key,0)+float(r['ScheduledPaidHours'])
        self.assertTrue(all(h<=40 for h in hours.values()))
    def test_duplicate_timecards_both_blocked(self):
        eligible=next(r for r in self.rows('FactTimekeeping') if r['EligibleForPay']=='1')
        cards=self.rows('timecards','inputs');match=next(r for r in cards if r['Date']==eligible['Date'] and r['EmployeeID']==eligible['EmployeeID']);cards.append(match.copy())
        self.replace('timecards',cards);self.run_pipeline()
        matches=[r for r in self.rows('FactTimekeeping') if r['Date']==match['Date'] and r['EmployeeID']==match['EmployeeID']]
        self.assertEqual(len(matches),2);self.assertTrue(all(r['EligibleForPay']=='0' for r in matches))
        self.assertFalse(any(r['Date']==match['Date'] and r['EmployeeID']==match['EmployeeID'] for r in self.rows('FactPay')))
    def test_bad_timecard_never_enters_pay(self):
        cards=self.rows('FactTimekeeping');pay=self.rows('FactPay');keys={(r['Date'],r['EmployeeID']) for r in pay}
        self.assertTrue(any(r['EligibleForPay']=='0' for r in cards))
        for r in cards:
            if r['EligibleForPay']=='0':self.assertNotIn((r['Date'],r['EmployeeID']),keys)
        for r in pay:self.assertAlmostEqual(float(r['RegularPay'])+float(r['OvertimePay']),float(r['IllustrativeGrossPay']),places=2)
    def test_moq_pack_and_reconciliation(self):
        p={r['ProductID']:r for r in self.rows('products','inputs')}
        for r in self.rows('FactPurchasing'):
            units=int(r['OrderUnits']);policy=p[r['ProductID']]
            self.assertEqual(units%int(policy['PackSize']),0)
            if units:self.assertGreaterEqual(units,int(policy['MOQ']))
            self.assertAlmostEqual(units*float(policy['Cost']),float(r['OrderCost']),places=2)
    def test_duplicate_sales_rejected(self):
        rows=self.rows('sales','inputs');rows.append(rows[0].copy());self.replace('sales',rows)
        self.assertIn('Duplicate sales grain',self.run_pipeline(success=False).stderr)

if __name__=='__main__':unittest.main()
