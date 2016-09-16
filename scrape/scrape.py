from robobrowser import RoboBrowser

import decimal
import json

ALL = 'all values'

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

    url = 'http://www.bjs.gov/ucrdata/Search/Crime/Local/RunCrimeOneYearofData.cfm'

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
        for cell in table.find_all('td', headers=True):
            if cell.attrs['headers'] == ['agency']:
                agency = cell.text.strip()
                print('agency ' + agency)
                bjs.data[state][year][agency] = {}
            else:
                bjs.data[state][year][agency][cell.attrs['headers'][-1]] = cast(cell.text)


with open('data.json', 'w') as outfile:
    json.dump(bjs.data, outfile, indent=2)
