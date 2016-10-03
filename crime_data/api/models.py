from __future__ import unicode_literals

from django.db import models

# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.



# Not Auto-generated - Summary data models

# class State(models.Model):
#     name = models.CharField(max_length=128, null=True)

# class County(models.Model):
#     name = models.CharField(max_length=128, null=True)

# class OffenseClass(models.Model):
#     name = models.CharField(max_length=128, null=True)
#     description = models.TextField(blank=True)

# class OffenseType(models.Model):
#     name = models.CharField(max_length=128, null=True)
#     offense_class = models.ForeignKey(OffenseClass)
#     description = models.TextField(blank=True)

# class CrimeCount(models.Model):
#     offense_type = models.ForeignKey(OffenseType, on_delete=models.CASCADE)
#     count = models.IntegerField(default=0)

# class CrimeStateYearly(models.Model):
#     '''''
#     Yearly Sums -> State Level.
#     '''''
#     year  = models.DateField()
#     state = models.ForeignKey(State, on_delete=models.CASCADE)
#     count = models.ForeignKey(CrimeCount)
#     class Meta:
#         unique_together = (('year', 'state'))

# class CrimeOriYearly(models.Model):
#     '''''
#     Yearly Sums -> Agency Level (NIBRS, and SRS)
#     '''''
#     year = models.DateField()
#     agency_id = models.ForeignKey(RefAgency, on_delete=models.CASCADE)
#     is_nibrs_summary = models.BooleanField(null=False)
#     count = models.ForeignKey(CrimeCount)
#     class Meta:
#         unique_together = (('year', 'agency_id'))

