# -*- coding: utf-8 -*-
# Generated by Django 1.10.7 on 2017-05-09 15:59
from __future__ import unicode_literals

from django.db import migrations, models


def makeUsersViewers(apps, schema_editor):
    """Make all non-admin users viewers."""
    PFBUser = Neighborhood = apps.get_model("users", "PFBUser")
    for user in PFBUser.objects.filter(role__in=('EDITOR', 'UPLOADER')):
        user.role = 'VIEWER'
        user.save()


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0003_auto_20170224_1639'),
    ]

    operations = [
        migrations.RunPython(makeUsersViewers),
        migrations.AlterField(
            model_name='pfbuser',
            name='role',
            field=models.CharField(choices=[('ADMIN', 'Administrator'), ('ORGADMIN', 'Organization Administrator'), ('VIEWER', 'Viewer')], default='VIEWER', max_length=8),
        ),
    ]