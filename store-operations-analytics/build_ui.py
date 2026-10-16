"""Refresh static UI data after running pipeline.py. No external dependencies."""
import csv,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
tables={p.stem:list(csv.DictReader(p.open())) for p in (ROOT/'outputs').glob('*.csv')}
for name in ['availability','employees','stores','products','inventory','timecards']:
    tables[name]=list(csv.DictReader((ROOT/'inputs'/f'{name}.csv').open()))
payload={'summary':json.loads((ROOT/'outputs/run-summary.json').read_text()),'tables':tables,'snapshot':'Synthetic demo • Forecast origin 1 Jan 2026'}
(ROOT/'ui/data.js').write_text('window.OPSDATA = '+json.dumps(payload,separators=(',',':'))+';\n')
print('Refreshed UI snapshot from pipeline output tables.')
