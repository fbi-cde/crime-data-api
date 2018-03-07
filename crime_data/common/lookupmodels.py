# coding: utf-8
import datetime
from decimal import Decimal

import flask_restful as restful
from crime_data.extensions import db
from sqlalchemy import (BigInteger, Boolean, Column, DateTime, Float,
                        ForeignKey, Integer, SmallInteger, String, Text,
                        UniqueConstraint, func, text, PrimaryKeyConstraint, ForeignKey)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import backref, relationship

# db = SQLAlchemy()

#Base = declarative_base()
#metadata = Base.metadata
class RefRegion(db.Model):
    __tablename__ = 'ref_region'
    region_id = db.Column(db.SmallInteger, primary_key=True)
    region_code = db.Column(db.String(2))
    region_name = db.Column(db.String(100))
    region_desc = db.Column(db.String(100))

class RegionLK(db.Model):
    __tablename__ = 'region_lk'

    def getByName(region_name=None):
        """
        A method to find a region by its region_name
        """
        query = RegionLK.query

        if region_name:
            query = query.filter(func.lower(RegionLK.region_name) == func.lower(region_name))
        return query

    region_code = db.Column(db.SmallInteger, primary_key=True)
    region_name = db.Column(db.String(50))
    region_desc = db.Column(db.String(100))

class StateLK(db.Model):
    __tablename__ = 'state_lk'

    def get(region_code=None,state_abbr=None):
        """
        A method to find a state by its region_code
        """
        query = StateLK.query

        if region_code:
            query = query.filter(StateLK.region_code == region_code)
        if state_abbr:
            query = query.filter(StateLK.state_abbr == state_abbr)

        return query

    state_id = db.Column(db.Integer, primary_key=True)
    state_abbr = db.Column(db.String(4))
    state_name = db.Column(db.String(50))
    state_fips_code  = db.Column(db.Integer)
    region_code = db.Column(db.SmallInteger)
