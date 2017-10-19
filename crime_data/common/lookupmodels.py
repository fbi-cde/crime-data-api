# coding: utf-8
import datetime
from decimal import Decimal

import flask_restful as restful
from crime_data.extensions import db
from sqlalchemy import (BigInteger, Boolean, Column, DateTime, Float,
                        ForeignKey, Integer, SmallInteger, String, Text,
                        UniqueConstraint, func, text, PrimaryKeyConstraint)
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
    __table_args__ = {"useexisting": True}
    region_code = db.Column(db.SmallInteger, primary_key=True)
    region_name = db.Column(db.String(50))
    region_desc = db.Column(db.String(100))

class StateLK(db.Model):
    __tablename__ = 'state_lk'
    __table_args__ = {"useexisting": True}
    state_id = db.Column(db.Integer, primary_key=True)
    state_abbr = db.Column(db.String(4))
    state_name = db.Column(db.String(50))
    state_fips_code  = db.Column(db.Integer)

class RegionStateLK(db.Model):
    __tablename__ = 'region_state_lk'
    region_code = db.Column(db.SmallInteger, primary_key=True)
    state_id = db.Column(db.Integer, primary_key=True)
