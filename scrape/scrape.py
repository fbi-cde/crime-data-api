from robobrowser import RoboBrowser

import decimal
import json

ALL = 'all values'

agencies_file = 'agencies.json'
states_file = 'states.json'

def cast(datum):
    try:
        return int(datum)
    except (ValueError, ):
        try:
            return decimal.Decimal(datum)
        except (ValueError, decimal.InvalidOperation):
            if not datum.strip():
                return None
            return datum.strip()

class BJS(object):

    field_map = {
        "months": "months_reporting",
        # "rape2": "forcible_rape_rate_per_1000",
        # "mvtheft2": "motor_vehicle_theft_rate_per_1000",
        # "murd2": "murder_rate_per_1000",
        # "pctot2": "property_crime_rate_total_per_1000",
        "aggr": "aggravated_assault",
        # "population": "population",
        "larc": "larceny",
        # "rob2": "robbery_per_1000",
        # "burg2": "burglary_per_1000",
        # "vctot2": "violent_crime_rate_per_1000",
        "murd": "murder",
        "vctot": "violent_crime_total",
        # "aggr2": "aggravated_assault_rate_per_1000",
        "state": "state",
        "pctot": "property_crime",
        "mvtheft": "motor_vehicle_theft",
        "burg": "burglary",
        # "larc2": "larceny_rate_per_1000",
        "rape": "forcible_rape",
        "rob": "robbery"
    }

    def __init__(self, url):
        self.url = url
        self.browser = RoboBrowser(history=True)
        self.data = {}


    def navigate(self, selections=[]):
        """
            selections: List of dicts,
        """
        self.browser.open(self.url)
        self.form = self.browser.get_form('CFForm_1')
        for sel in selections:
            if 'submit' in sel:
                which_submit = self.form.submit_fields[sel.pop('submit')]
            else:
                which_submit = None
            for key in sel:
                if sel[key] == ALL:
                    self.form[key].value = self.form[key].options
                else:
                    self.form[key].value = sel[key]
            self.browser.submit_form(self.form, which_submit)
            self.form = self.browser.get_form('CFForm_1')


bjs = BJS('http://www.bjs.gov/ucrdata/Search/Crime/State/OneYearofData.cfm')
bjs.navigate()

states = bjs.form['StateId'].options
years = bjs.form['YearStart'].options
state_labels = bjs.form['StateId'].labels
print("=========== STARTING STATE LEVEL BJS SCRAPE ============")
for (index, state_id) in enumerate(states):
    state = state_labels[index].strip()
    bjs.data[state] = {}

    for year in years:
        bjs.data[state][year] = {}
        navigation = {'StateId': state, 'YearStart': year, 'DataType': ALL, 'submit': 'NextPage'}
        bjs.navigate([navigation])
        table = bjs.browser.find('table', title='Data table: crime, state level, one year of data')

        if table is not None:
            for cell in table.find_all('td', headers=True):
                if cell.attrs['headers'] == ['state']:
                    bjs.data[state][year] = {}
                else:
                    #bjs.data[state][year][cell.attrs['headers'][-1]] = cast(cell.text)
                    key = cell.attrs['headers'][-1]
                    # If it's not in the field map, we don't care about it.
                    if key in bjs.field_map:
                        field = bjs.field_map[key]
                        value = cell.text.replace(',','')
                        value = cast(value)
                        bjs.data[state][year][field] = value
        else:
            bjs.data[state][year] = {}

with open(states_file, 'w') as outfile:
    print("DUMPING STATES DATA TO " + states_file)
    json.dump(bjs.data, outfile, indent=2)

print("=========== STARTING AGENCY LEVEL BJS SCRAPE ============")

bjs = BJS('http://www.bjs.gov/ucrdata/Search/Crime/Local/RunCrimeOneYearofData.cfm')
bjs.navigate()
states = bjs.form['StateId'].options
state_labels = bjs.form['StateId'].labels
for (index, state_id) in enumerate(states):
    state = state_labels[index].strip()
    print('State ' + state)
    bjs.data[state] = {}
    bjs.navigate([{'StateId': state_id}])
    years = bjs.form['YearStart'].options
    for year_str in years:
        year = cast(year_str)
        print('Year %s' % year)
        bjs.data[state][year] = {}
        navigation = {'YearStart': year_str, 'CrimeCrossId': ALL, 'DataType': ALL, 'submit': 'NextPage'}
        bjs.navigate([{'StateId': state_id}, navigation])

        table = bjs.browser.find('table', title='Data table: crime, local-level, one year of data')
        agency = None
        if table is not None:
            for cell in table.find_all('td', headers=True):
                if cell.attrs['headers'] == ['agency']:
                    agency = cell.text.strip()
                    print('agency ' + agency)
                    bjs.data[state][year][agency] = {}
                else:
                    key = cell.attrs['headers'][-1]
                    # If it's not in the field map, we don't care about it.
                    if key in bjs.field_map:
                        field = bjs.field_map[key]
                        value = cell.text.replace(',','')
                        value = cast(value)
                        bjs.data[state][year][agency][field] = value
        else:
            bjs.data[state][year][agency] = value


with open(agencies_file, 'w') as outfile:
    print("DUMPING AGENCIES DATA TO " + agencies_file)
    json.dump(bjs.data, outfile, indent=2)
