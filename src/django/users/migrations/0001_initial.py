# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2017-02-21 16:19
from __future__ import unicode_literals

from django.conf import settings
from django.contrib.auth.hashers import make_password
from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone
import django.db.models.deletion
import users.models
import uuid


def add_root_user(apps, schema_editor):
    """Create root user to enable making root user required"""

    PFBUser = apps.get_model('users', 'PFBUser')
    root_user = PFBUser(role='ADMIN',
                        password='root',
                        email='systems+pfb@azavea.com',
                        uuid='bba2038e-863e-4c1e-a64c-c06b6000a61f')
    root_user.save()

    root_user.created_by = root_user
    root_user.modified_by = root_user
    root_user.save()

    # set_password is not available in migrations, so set this way. see:
    # https://code.djangoproject.com/ticket/26445
    root_user.password = make_password('root')
    root_user.save()


def delete_root_user(apps, schema_editor):
    """Deletes root user for backwards migration"""
    PFBUser = apps.get_model('users', 'PFBUser')
    root_user = PFBUser.objects.get(email='systems+pfb@azavea.com')
    root_user.delete()


def add_root_org(apps, schema_editor):
    PFBUser = apps.get_model('users', 'PFBUser')
    root_user = PFBUser.objects.get(email='systems+pfb@azavea.com')

    Organization = apps.get_model('users', 'Organization')
    root_org = Organization.objects.create(created_by=root_user,
                                           modified_by=root_user,
                                           name='root',
                                           org_type='ADMIN',
                                           label='Default administrative organization')
    root_org.save()

    root_user.organization = root_org
    root_user.save()


def delete_root_org(apps, schema_editor):
    Organization = apps.get_model('users', 'Organization')
    root_org = Organization.objects.get(name='root')
    root_org.delete()


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('auth', '0008_alter_user_username_max_length'),
        ('pfb_network_connectivity', '__first__'),
    ]

    operations = [
        migrations.CreateModel(
            name='PFBUser',
            fields=[
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('is_superuser', models.BooleanField(default=False, help_text='Designates that this user has all permissions without explicitly assigning them.', verbose_name='superuser status')),
                ('uuid', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('modified_at', models.DateTimeField(auto_now=True)),
                ('email', models.EmailField(error_messages={'unique': 'A user with that email already exists'}, help_text='Required. A valid email address', max_length=254, unique=True, verbose_name='email address')),
                ('first_name', models.CharField(blank=True, max_length=30, verbose_name='first name')),
                ('last_name', models.CharField(blank=True, max_length=30, verbose_name='last name')),
                ('role', models.CharField(choices=[('ADMIN', 'Administrator'), ('VIEWER', 'Viewer'), ('EDITOR', 'Editor'), ('UPLOADER', 'Uploader')], default='VIEWER', max_length=8)),
                ('is_staff', models.BooleanField(default=False, help_text='Designates whether the user can log into this admin site.', verbose_name='staff status')),
                ('is_active', models.BooleanField(default=True, help_text='Designates whether this user should be treated as active. Unselect this instead of deleting accounts.', verbose_name='active')),
                ('date_joined', models.DateTimeField(default=django.utils.timezone.now, verbose_name='date joined')),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, related_name='users_pfbuser_related+', to=settings.AUTH_USER_MODEL)),
                ('groups', models.ManyToManyField(blank=True, help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.', related_name='user_set', related_query_name='user', to='auth.Group', verbose_name='groups')),
                ('modified_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, related_name='users_pfbuser_related+', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'pfbuser',
                'verbose_name_plural': 'pfbusers',
            },
            managers=[
                ('objects', users.models.PFBUserManager()),
            ],
        ),
        migrations.CreateModel(
            name='Organization',
            fields=[
                ('uuid', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('modified_at', models.DateTimeField(auto_now=True)),
                ('name', models.CharField(max_length=255, unique=True)),
                ('label', models.SlugField(unique=True)),
                ('org_type', models.CharField(choices=[('ADMIN', 'PFB Administrator Organization'), ('NEIGHBORHOOD', 'Neighborhood'), ('SUBSCRIBER', 'Subscriber')], max_length=10)),
                ('created_by', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='users_organization_related+', to=settings.AUTH_USER_MODEL)),
                ('modified_by', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='users_organization_related+', to=settings.AUTH_USER_MODEL)),
                ('neighborhood', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='pfb_network_connectivity.Neighborhood')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.AddField(
            model_name='pfbuser',
            name='user_permissions',
            field=models.ManyToManyField(blank=True, help_text='Specific permissions for this user.', related_name='user_set', related_query_name='user', to='auth.Permission', verbose_name='user permissions'),
        ),
        migrations.RunPython(
            code=add_root_user,
            reverse_code=delete_root_user,
        ),
        migrations.AlterField(
            model_name='pfbuser',
            name='created_by',
            field=models.ForeignKey(null=False, on_delete=django.db.models.deletion.PROTECT, related_name='users_pfbuser_related+', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AlterField(
            model_name='pfbuser',
            name='modified_by',
            field=models.ForeignKey(null=False, on_delete=django.db.models.deletion.PROTECT, related_name='users_pfbuser_related+', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='pfbuser',
            name='organization',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, to='users.Organization'),
        ),
        migrations.RunPython(
            code=add_root_org,
            reverse_code=delete_root_org,
        ),
        migrations.AlterField(
            model_name='pfbuser',
            name='organization',
            field=models.ForeignKey(null=False, on_delete=django.db.models.deletion.CASCADE, to='users.Organization'),
        ),
    ]
