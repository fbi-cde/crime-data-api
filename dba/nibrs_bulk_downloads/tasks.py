import luigi
import luigi.tools.deps as luigi_deps
import os
import subprocess as sp #nosec
import glob
import shutil


class RebuildIfOldTask(luigi.Task):
    def is_outdated(self):
        deps = luigi_deps.find_deps(self, luigi_deps.upstream().family)
        deps.discard(self)
        dep_paths = [o.path for o in luigi.task.flatten([dep.output() for dep in deps])]
        max_dep_mtime = 0

        for path in dep_paths:
            if os.path.exists(path):
                if os.path.getmtime(path) > max_dep_mtime:
                    max_dep_mtime = os.path.getmtime(path)
            else:
                # missing an upstream dep, so must rebuild too
                return True

        # now check if any of our own outputs are missing or < max_dep_mtime
        local_paths = [o.path for o in luigi.task.flatten(self.output())]
        for path in local_paths:
            if os.path.exists(path):
                if os.path.getmtime(path) < max_dep_mtime:
                    return True
            else:
                return True

        return False

    def complete(self):
        if self.is_outdated():
            for out in luigi.task.flatten(self.output()):
                if out.exists():
                    os.remove(self.output().path)
            return False
        else:
            return True


CODE_TABLES_DIR = 'code_tables'
DATA_DIR = 'data'
ZIPS_DIR = 'zips'
MAX_YEAR = 2016

STATE_YEARS = {
    'AL': [1991, 1992] + list(range(2006, MAX_YEAR+1)),
    'AR': range(1999, MAX_YEAR+1),
    'AZ': range(2004, MAX_YEAR+1),
    'CO': [1992, 1993, 1994] + list(range(1997, MAX_YEAR+1)),
    'CT': range(1998, MAX_YEAR+1),
    'DC': range(2000, MAX_YEAR+1),
    'DE': range(2001, MAX_YEAR+1),
    'IA': range(1992, MAX_YEAR+1),
    'ID': range(1992, MAX_YEAR+1),
    'IL': [1993, 1994] + list(range(2006, MAX_YEAR+1)),
    'IN': range(2013, MAX_YEAR+1),
    'KS': range(2000, MAX_YEAR+1),
    'KY': range(1998, MAX_YEAR+1),
    'LA': range(2003, MAX_YEAR+1),
    'MA': range(1994, MAX_YEAR+1),
    'ME': range(2004, MAX_YEAR+1),
    'MI': range(1995, MAX_YEAR+1),
    'MO': range(2006, MAX_YEAR+1),
    'MT': range(2005, MAX_YEAR+1),
    'ND': range(1991, MAX_YEAR+1),
    'NE': range(1998, MAX_YEAR+1),
    'NH': range(2002, MAX_YEAR+1),
    'OH': range(1998, MAX_YEAR+1),
    'OK': range(2008, MAX_YEAR+1),
    'OR': range(2003, MAX_YEAR+1),
    'PA': range(2012, MAX_YEAR+1),
    'RI': range(2004, MAX_YEAR+1),
    'SC': range(1991, MAX_YEAR+1),
    'SD': range(2000, MAX_YEAR+1),
    'TN': range(1997, MAX_YEAR+1),
    'TX': range(1997, MAX_YEAR+1),
    'UT': range(1993, MAX_YEAR+1),
    'VA': range(1994, MAX_YEAR+1),
    'VT': range(1993, MAX_YEAR+1),
    'WA': range(2005, MAX_YEAR+1),
    'WI': range(2004, MAX_YEAR+1),
    'WV': range(1998, MAX_YEAR+1)
}


def run_select(sql, path):
    """ Run SQL against the database """
    temp_file = path + '.tmp'
    query = "SET work_mem='1GB'; \copy ({}) TO '{}' WITH CSV DELIMITER ',' HEADER;".format(sql, temp_file)
    print(query)

    p = None
    if os.getenv('DB_URI'):
        p = sp.run(['psql', os.getenv('DB_URI')], stdout=sp.PIPE, input=query, encoding='ascii')
    else:
        p = sp.run(['cf', 'connect-to-service', 'crime-data-api', 'crime-data-upload-db'], stdout=sp.PIPE,
               input=query, encoding='ascii')

    if p.returncode == 0 and os.stat(temp_file).st_size > 0:
        # if everything worked, we can move to final path
        os.rename(temp_file, path)
    else:
        os.unlink(path)
        raise "Error exporting " + path

    
class CodeTableTask(luigi.Task):
    def local_path(self):
        return os.path.join(CODE_TABLES_DIR, self.table_name + '.csv')
        
    def output(self):
        return luigi.LocalTarget(self.local_path())

    def run(self):
        run_select('select * from {}'.format(self.table_name), self.local_path())


class ZipReadme(luigi.Task):
    def local_path(self):
        return os.path.join(CODE_TABLES_DIR, 'README.html')

    def markdown_path(self):
        return os.path.join(CODE_TABLES_DIR, 'README.md')

    def output(self):
        if os.path.exists(self.local_path()):
            md_time = os.path.getmtime(self.markdown_path())
            ht_time = os.path.getmtime(self.local_path())

            # hack to delete the HTML file if older than the markdown one
            if md_time > ht_time:
                os.unlink(self.local_path())

        return luigi.LocalTarget(self.local_path())

    def run(self):
        sp.run(['grip', '--wide', '--export', self.markdown_path(), self.local_path()])
        
        
# Code tables
class NibrsActivityType(CodeTableTask):
    table_name = 'nibrs_activity_type'

class NibrsAge(CodeTableTask):
    table_name = 'nibrs_age'

class NibrsArrestType(CodeTableTask):
    table_name = 'nibrs_arrest_type'
    
class NibrsAssignmentType(CodeTableTask):
    table_name = 'nibrs_assignment_type'

class NibrsBiasList(CodeTableTask):
    table_name = 'nibrs_bias_list'

class NibrsCircumstances(CodeTableTask):
    table_name = 'nibrs_circumstances'

class NibrsClearedExcept(CodeTableTask):
    table_name = 'nibrs_cleared_except'
    
class NibrsCriminalActType(CodeTableTask):
    table_name = 'nibrs_criminal_act_type'

class NibrsDrugMeasureType(CodeTableTask):
    table_name = 'nibrs_drug_measure_type'

class NibrsEthnicity(CodeTableTask):
    table_name = 'nibrs_ethnicity'

class NibrsInjury(CodeTableTask):
    table_name = 'nibrs_injury'

class NibrsJustifiableForce(CodeTableTask):
    table_name = 'nibrs_justifiable_force'
    
class NibrsLocationType(CodeTableTask):
    table_name = 'nibrs_location_type'

class NibrsOffenseType(CodeTableTask):
    table_name = 'nibrs_offense_type'

class NibrsPropDescType(CodeTableTask):
    table_name = 'nibrs_prop_desc_type'

class NibrsPropLossType(CodeTableTask):
    table_name = 'nibrs_prop_loss_type'
    
class RefRace(CodeTableTask):
    table_name = 'ref_race'

class RefState(CodeTableTask):
    table_name = 'ref_state'

class NibrsRelationship(CodeTableTask):
    table_name = 'nibrs_relationship'
    
class NibrsSuspectedDrugType(CodeTableTask):
    table_name = 'nibrs_suspected_drug_type'

class NibrsUsingList(CodeTableTask):
    table_name = 'nibrs_using_list'

class NibrsVictimType(CodeTableTask):
    table_name = 'nibrs_victim_type'
    
class NibrsWeaponType(CodeTableTask):
    table_name = 'nibrs_weapon_type'
    
class CodeTables(luigi.WrapperTask):
    def requires(self):
        return [NibrsActivityType(), NibrsAge(), NibrsArrestType(),
                NibrsAssignmentType(), NibrsBiasList(), NibrsCircumstances(),
                NibrsCriminalActType(), NibrsDrugMeasureType(), NibrsEthnicity(),
                NibrsInjury(), NibrsJustifiableForce(), NibrsLocationType(),
                NibrsOffenseType(), NibrsPropDescType(), NibrsPropLossType(),
                RefRace(), RefState(), NibrsClearedExcept(),
                NibrsRelationship(), NibrsSuspectedDrugType(), NibrsUsingList(),
                NibrsVictimType(), NibrsWeaponType()]


# Other tables
class DataTableTask(luigi.Task):
    year = luigi.IntParameter()
    state = luigi.Parameter()
    
    def local_path(self):
        return os.path.join(DATA_DIR, self.state, str(self.year), self.table_name + '.csv')

    def output(self):
        return luigi.LocalTarget(self.local_path())

    def run(self):
        self.output().makedirs()
        run_select(self.query.format(year=self.year, state=self.state),
                   self.local_path())


class CdeAgencies(DataTableTask):
    table_name = 'cde_agencies'
    query = "select DISTINCT c.* from cde_agencies c \
             JOIN nibrs_month nm ON nm.agency_id = c.agency_id \
             WHERE nm.data_year = {year} AND c.state_abbr = '{state}'"


class AgencyParticipation(DataTableTask):
    table_name = 'agency_participation'
    query = "select * from agency_participation where state_abbr = '{state}' AND year = {year}"

    
class NibrsMonth(DataTableTask):
    table_name = 'nibrs_month'
    query =  "SELECT nm.* from nibrs_month nm \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"

    
class NibrsIncident(DataTableTask):
    table_name = 'nibrs_incident'
    query =  "SELECT ni.* FROM nibrs_incident ni \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"

    
class NibrsOffense(DataTableTask):
    table_name = 'nibrs_offense'
    query =  "SELECT o.* FROM nibrs_offense o \
    JOIN nibrs_incident ni ON ni.incident_id = o.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsOffender(DataTableTask):
    table_name = 'nibrs_offender'
    query =  "SELECT o.* FROM nibrs_offender o \
    JOIN nibrs_incident ni ON ni.incident_id = o.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"
    

class NibrsVictim(DataTableTask):
    table_name = 'nibrs_victim'
    query =  "SELECT v.* FROM nibrs_victim v \
    JOIN nibrs_incident ni ON ni.incident_id = v.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsProperty(DataTableTask):
    table_name = 'nibrs_property'
    query =  "SELECT p.* FROM nibrs_property p \
    JOIN nibrs_incident ni ON ni.incident_id = p.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsPropertyDesc(DataTableTask):
    table_name = 'nibrs_property_desc'
    query =  "SELECT pd.* FROM nibrs_property_desc pd \
    JOIN nibrs_property p ON p.property_id = pd.property_id \
    JOIN nibrs_incident ni ON ni.incident_id = p.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsSuspectedDrug(DataTableTask):
    table_name = 'nibrs_suspected_drug'
    query =  "SELECT sd.* FROM nibrs_suspected_drug sd \
    JOIN nibrs_property p ON p.property_id = sd.property_id \
    JOIN nibrs_incident ni ON ni.incident_id = p.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsArrestee(DataTableTask):
    table_name = 'nibrs_arrestee'
    query =  "SELECT a.* FROM nibrs_arrestee a \
    JOIN nibrs_incident ni ON ni.incident_id = a.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsArresteeWeapon(DataTableTask):
    table_name = 'nibrs_arrestee_weapon'
    query =  "SELECT aw.* FROM nibrs_arrestee_weapon aw \
    JOIN nibrs_arrestee a ON a.arrestee_id = aw.arrestee_id \
    JOIN nibrs_incident ni ON ni.incident_id = a.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"

    
class NibrsVictimOffenderRel(DataTableTask):
    table_name = 'nibrs_victim_offender_rel'
    query =  "SELECT vo.* FROM nibrs_victim_offender_rel vo \
    JOIN nibrs_victim v ON v.victim_id = vo.victim_id \
    JOIN nibrs_incident ni ON ni.incident_id = v.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsVictimInjury(DataTableTask):
    table_name = 'nibrs_victim_injury'
    query =  "SELECT vo.* FROM nibrs_victim_injury vo \
    JOIN nibrs_victim v ON v.victim_id = vo.victim_id \
    JOIN nibrs_incident ni ON ni.incident_id = v.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsVictimCircumstances(DataTableTask):
    table_name = 'nibrs_victim_circumstances'
    query =  "SELECT vo.* FROM nibrs_victim_circumstances vo \
    JOIN nibrs_victim v ON v.victim_id = vo.victim_id \
    JOIN nibrs_incident ni ON ni.incident_id = v.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"
    
class NibrsVictimOffense(DataTableTask):
    table_name = 'nibrs_victim_offense'
    query =  "SELECT vo.* FROM nibrs_victim_offense vo \
    JOIN nibrs_victim v ON v.victim_id = vo.victim_id \
    JOIN nibrs_incident ni ON ni.incident_id = v.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"

    
class NibrsWeapon(DataTableTask):
    table_name = 'nibrs_weapon'
    query =  "SELECT w.* FROM nibrs_weapon w \
    JOIN nibrs_offense o ON o.offense_id = w.offense_id \
    JOIN nibrs_incident ni ON ni.incident_id = o.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"

class NibrsCriminalAct(DataTableTask):
    table_name = 'nibrs_criminal_act'
    query =  "SELECT c.* FROM nibrs_criminal_act c \
    JOIN nibrs_offense o ON o.offense_id = c.offense_id \
    JOIN nibrs_incident ni ON ni.incident_id = o.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsSuspectUsing(DataTableTask):
    table_name = 'nibrs_suspect_using'
    query =  "SELECT c.* FROM nibrs_suspect_using c \
    JOIN nibrs_offense o ON o.offense_id = c.offense_id \
    JOIN nibrs_incident ni ON ni.incident_id = o.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"


class NibrsBiasMotivation(DataTableTask):
    table_name = 'nibrs_bias_motivation'
    query =  "SELECT c.* FROM nibrs_bias_motivation c \
    JOIN nibrs_offense o ON o.offense_id = c.offense_id \
    JOIN nibrs_incident ni ON ni.incident_id = o.incident_id \
    JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id \
    JOIN ref_agency ra ON ra.agency_id = nm.agency_id \
    JOIN ref_state rs ON rs.state_id = ra.state_id \
    WHERE rs.state_postal_abbr = '{state}' AND nm.data_year = {year}"
    

class DataTables(luigi.WrapperTask):
    year = luigi.IntParameter()
    state = luigi.Parameter()

    def requires(self):
        yield AgencyParticipation(year=self.year, state=self.state)
        yield CdeAgencies(year=self.year, state=self.state)
        yield NibrsArrestee(year=self.year, state=self.state)
        yield NibrsArresteeWeapon(year=self.year, state=self.state)
        yield NibrsBiasMotivation(year=self.year, state=self.state)
        yield NibrsCriminalAct(year=self.year, state=self.state)
        yield NibrsIncident(year=self.year, state=self.state)
        yield NibrsMonth(year=self.year, state=self.state)
        yield NibrsOffender(year=self.year, state=self.state)
        yield NibrsOffense(year=self.year, state=self.state)
        yield NibrsProperty(year=self.year, state=self.state)
        yield NibrsPropertyDesc(year=self.year, state=self.state)
        yield NibrsSuspectUsing(year=self.year, state=self.state)
        yield NibrsSuspectedDrug(year=self.year, state=self.state)
        yield NibrsVictim(year=self.year, state=self.state)
        yield NibrsVictimCircumstances(year=self.year, state=self.state)
        yield NibrsVictimInjury(year=self.year, state=self.state)
        yield NibrsVictimOffenderRel(year=self.year, state=self.state)
        yield NibrsVictimOffense(year=self.year, state=self.state)
        yield NibrsWeapon(year=self.year, state=self.state)


class StateFiles(luigi.WrapperTask):
    year = luigi.IntParameter()
    state = luigi.Parameter()

    def requires(self):
        return CodeTables(), DataTables(year=self.year, state=self.state)
    
        
class ZipFile(RebuildIfOldTask):
    year = luigi.IntParameter()
    state = luigi.Parameter()

    def requires(self):
        return ZipReadme(), CodeTables(), DataTables(year=self.year, state=self.state)

    def data_dir(self):
        return os.path.join(DATA_DIR, self.state, str(self.year))
    
    def local_path(self):
        return os.path.join(ZIPS_DIR, str(self.year), '{state}-{year}.zip'.format(state=self.state, year=self.year))

    def output(self):
        return luigi.LocalTarget(self.local_path())

    def run(self):
        self.output().makedirs()
        p = sp.run(['zip', '-9rj', self.local_path(), CODE_TABLES_DIR])
        p = sp.run(['zip', '-9rj', self.local_path(), self.data_dir()])


class AllState(luigi.WrapperTask):
    state = luigi.Parameter()

    def requires(self):
        for year in STATE_YEARS[self.state]:
            yield StateFiles(year=year, state=self.state)
        

class AllYear(luigi.WrapperTask):
    year = luigi.IntParameter()
    
    def requires(self):
        yield CodeTables()

        for state in STATE_YEARS.keys():
            if self.year in STATE_YEARS[state]:
                yield StateFiles(state=state, year=self.year)

            
class AllStates(luigi.WrapperTask):
    def requires(self):
        yield CodeTables()

        for state in STATE_YEARS.keys():
            yield AllState(state=state)

            
class AllZips(luigi.WrapperTask):
    def requires(self):
        yield CodeTables()

        for state in STATE_YEARS.keys():
            for year in STATE_YEARS[state]:
                yield ZipFile(state=state, year=year)
    
