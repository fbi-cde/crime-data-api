from django.db import models

class State(models.Model):
    name = models.CharField(max_length=128, null=True)

class County(models.Model):
    name = models.CharField(max_length=128, null=True)

class Race(models.Model):
    name = models.CharField(max_length=128, null=True)

class AgencyOri(models.Model):
    name = models.CharField(max_length=128, null=True)
    city = models.CharField(max_length=128, null=True)
    state = models.ForeignKey(State)
    county = models.ForeignKey(County)

class Person(models.Model):
    name = models.CharField(max_length=256)
    race = models.ForeignKey(Race)
    sex = models.CharField(max_length=128, null=True)

class WeaponType(models.Model):
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class OffenseClass(models.Model):
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class OffenseType(models.Model):
    name = models.CharField(max_length=128, null=True)
    offense_class = models.ForeignKey(OffenseClass)
    description = models.TextField(blank=True)

class Clearance(models.Model):
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class Circumstance(models.Model):
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class CrimeType(models.Model):
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class LocationType(models.Model):
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class Relationship(models.Model):
    '''''
    Victim + Offender relationship
    '''''
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class CrimeCount(models.Model):
    offense_type = models.ForeignKey(OffenseType, on_delete=models.CASCADE)
    count = models.IntegerField(default=0)

class CrimeStateYearly(models.Model):
    '''''
    Yearly Sums -> State Level.
    '''''
    year  = models.DateField()
    state = models.ForeignKey(State, on_delete=models.CASCADE)
    count = models.ForeignKey(CrimeCount)
    class Meta:
        unique_together = (('year', 'state'))

class CrimeOriYearly(models.Model):
    '''''
    Yearly Sums -> Agency Level (NIBRS, and SRS)
    '''''
    year = models.DateField()
    agency_ori = models.ForeignKey(AgencyOri, on_delete=models.CASCADE)
    is_nibrs_summary = models.BooleanField(null=False)
    count = models.ForeignKey(CrimeCount)
    class Meta:
        unique_together = (('year', 'agency_ori'))

class Incident(models.Model):
    '''''
    NIBRS - Incident Level data.
    '''''
    date  = models.DateField(null=False)
    offender = models.ForeignKey(Person, related_name='+')
    victim = models.ForeignKey(Person, related_name='+')
    crime_type = models.ForeignKey(CrimeType)
    location_type = models.ForeignKey(LocationType)
    relationship = models.ForeignKey(Relationship) # Victim + Offender relationship
    weapon_type = models.ForeignKey(WeaponType)
    circumstance = models.ForeignKey(Circumstance)
    time_of_day_gmt = models.IntegerField(default=0)
    completed = models.BooleanField() # Boolean.
    clearance  = models.ForeignKey(Clearance)
    offense_type = models.ForeignKey(OffenseType)



