import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {buildScenario,sum,rowsFor,isoWeek,csvText,modules} from './core.mjs';
const context={window:{}};vm.runInNewContext(fs.readFileSync(new URL('./data.js',import.meta.url),'utf8'),context);
const tables=JSON.parse(JSON.stringify(context.window.OPSDATA.tables));const baseline=buildScenario(tables);
test('default browser model reconciles all seven Python planning outputs',()=>{
 for(const [name,key] of [['FactForecast','ForecastUnits'],['FactLaborForecast','RequiredHours'],['FactPurchasing','OrderCost'],['FactSchedule','ScheduledPaidHours'],['FactCoverage','UnfilledHours'],['FactTimekeeping','EligibleForPay'],['FactPay','IllustrativeGrossPay']]){
  assert.equal(baseline[name].length,tables[name].length,name+' row count');
  assert.ok(Math.abs(sum(baseline[name],key)-sum(tables[name],key))<.02,name+' total');}
 for(const name of ['FactCoverage','FactPay'])for(let i=0;i<baseline[name].length;i++){for(const key of Object.keys(tables[name][i])){
  const a=baseline[name][i][key],b=tables[name][i][key];if(Number.isFinite(Number(b)))assert.ok(Math.abs(Number(a)-Number(b))<.02,`${name}[${i}].${key}`);else assert.equal(a,b);}}
});
test('demand increase propagates to labor, purchasing, roster and eligibility',()=>{
 const next=buildScenario(tables,{uplift:50,productivity:30,stock:0});
 assert.ok(sum(next.FactForecast,'ForecastUnits')>sum(baseline.FactForecast,'ForecastUnits'));
 assert.ok(sum(next.FactLaborForecast,'RequiredHours')>sum(baseline.FactLaborForecast,'RequiredHours'));
 assert.ok(sum(next.FactPurchasing,'OrderCost')>sum(baseline.FactPurchasing,'OrderCost'));
 assert.ok(sum(next.FactCoverage,'UnfilledHours')>sum(baseline.FactCoverage,'UnfilledHours'));
 assert.ok(next.FactPay.length>=baseline.FactPay.length);
 assert.equal(tables.timecards[0].ClockOut,'','Independent punches stay unchanged');
});
test('inventory increase changes replenishment, not required labor',()=>{
 const next=buildScenario(tables,{stock:600,productivity:30,uplift:0});
 assert.ok(sum(next.FactPurchasing,'OrderCost')<sum(baseline.FactPurchasing,'OrderCost'));
 assert.equal(sum(next.FactLaborForecast,'RequiredHours'),sum(baseline.FactLaborForecast,'RequiredHours'));
});
test('roster respects availability and ISO-week caps under high demand',()=>{
 const next=buildScenario(tables,{uplift:50,productivity:20,stock:0}),hours=new Map();
 for(const r of next.FactSchedule){const key=r.EmployeeID+'|'+isoWeek(r.Date);hours.set(key,(hours.get(key)||0)+r.ScheduledPaidHours);const wd=(new Date(r.Date+'T00:00:00Z').getUTCDay()+6)%7;assert.ok(tables.availability.some(a=>a.EmployeeID===r.EmployeeID&&+a.Weekday===wd&&+a.Available===1));}
 assert.ok([...hours.values()].every(h=>h<=40));assert.equal(isoWeek('2026-01-01'),'2026-1');
});
test('invalid and duplicate timecards cannot enter pay',()=>{
 const fixture=JSON.parse(JSON.stringify(tables));const good=fixture.FactTimekeeping.find(r=>+r.EligibleForPay===1);const t=fixture.timecards.find(r=>r.Date===good.Date&&r.EmployeeID===good.EmployeeID);fixture.timecards.push({...t});const next=buildScenario(fixture);
 assert.equal(next.FactTimekeeping.filter(r=>r.Date===t.Date&&r.EmployeeID===t.EmployeeID&&r.EligibleForPay).length,0);
 assert.equal(next.FactPay.filter(r=>r.Date===t.Date&&r.EmployeeID===t.EmployeeID).length,0);
 for(const r of next.FactTimekeeping.filter(r=>!r.EligibleForPay))assert.ok(!next.FactPay.some(p=>p.Date===r.Date&&p.EmployeeID===r.EmployeeID));
});
test('store filters, shared dependency graph and CSV export preserve meaning',()=>{
 assert.equal(rowsFor(baseline.FactForecast,'1').length,21);assert.equal(rowsFor(tables.DimProduct,'1').length,3);
 for(const m of modules)for(const id of m.children)assert.ok(modules.find(n=>n.id===id).parents.includes(m.id));
 assert.equal(csvText([{a:'x,"y',b:'line\nbreak'}]),'"a","b"\r\n"x,""y","line\nbreak"');
});
