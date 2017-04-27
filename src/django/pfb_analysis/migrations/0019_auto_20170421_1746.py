# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2017-04-21 17:46
from __future__ import unicode_literals

from django.db import migrations, models
import pfb_analysis.models


class Migration(migrations.Migration):

    dependencies = [
        ('pfb_analysis', '0018_add_neighborhood_geom_pt'),
    ]

    operations = [
        migrations.AlterField(
            model_name='neighborhood',
            name='boundary_file',
            field=models.FileField(help_text='A zipped shapefile boundary to run the bike network analysis on', max_length=1024, upload_to=pfb_analysis.models.get_neighborhood_file_upload_path),
        ),
    ]