# -*- coding: utf-8 -*-
"""Factories to help in tests."""
from factory import PostGenerationMethodCall, Sequence, LazyAttribute, SubFactory
from factory.alchemy import SQLAlchemyModelFactory

from crime_data.database import db
from crime_data.common import models as m
from tests import conftest

class BaseFactory(SQLAlchemyModelFactory):
    """Base factory."""

    class Meta:
        """Factory configuration."""

        abstract = True
#        sqlalchemy_session = conftest.Session
        sqlalchemy_session = db.session
        force_flush = True


class RefCountyFactory(BaseFactory):

    class Meta:
        model = m.RefCounty

    county_id = Sequence(lambda n: n+10000)
    state_id = 31 # Nebraska


class RefAgencyFactory(BaseFactory):

    class Meta:
        model = m.RefAgency

    agency_id = Sequence(lambda n: n+10000)
    ori = Sequence(lambda n: 'ZZ%07d' % n)
    legacy_ori = LazyAttribute(lambda obj: obj.ori)
    ucr_agency_name = Sequence(lambda n: 'Factory Agency %0d' % n)
    ncic_agency_name = LazyAttribute(lambda obj: obj.ucr_agency_name)
    state_id = 31 # Nebraska
    agency_type_id = 1 # City
    agency_status = 'A'
    population_family_id = 2 # City


class RefAgencyCountyFactory(BaseFactory):

    class Meta:
        model = m.RefAgencyCounty

    data_year = 2014
    agency = SubFactory(RefAgencyFactory)
    county = SubFactory(RefCountyFactory)
    metro_div_id = 411 # Not Specified
