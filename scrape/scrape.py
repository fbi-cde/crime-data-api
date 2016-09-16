from robobrowser import RoboBrowser
import json

ALL = 'all values'

class BJS(object):

    url = 'http://www.bjs.gov/ucrdata/Search/Crime/Local/RunCrimeOneYearofData.cfm'

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

    def __init__(self):
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


bjs = BJS()
bjs.navigate()
states = bjs.form['StateId'].options
for state in states:
    print('State ' + state)
    bjs.data[state] = {}
    bjs.navigate([{'StateId': state}])
    years = bjs.form['YearStart'].options

    for year in years:
        print('Year ' + year)
        bjs.data[state][year] = {}
        navigation = {'YearStart': year, 'CrimeCrossId': ALL, 'DataType': ALL, 'submit': 'NextPage'}
        bjs.navigate([{'StateId': state}, navigation])

        table = bjs.browser.find('table', title='Data table: crime, local-level, one year of data')
        agency = None
        for cell in table.find_all('td', headers=True):
            if cell.attrs['headers'] == ['agency']:
                agency = cell.text
                print('agency ' + agency)
                bjs.data[state][year][agency] = {}
            else:
                key = cell.attrs['headers'][-1]
                # If it's not in the field map, we don't care about it.
                if key in bjs.field_map:
                    field = bjs.field_map[key]
                    value = cell.text.strip().replace(',','')
                    try:
                        value = int(value)
                    except:
                        pass
                    bjs.data[state][year][agency][field] = value


with open('data.json', 'w') as outfile:
    json.dump(bjs.data, outfile, indent=2)
