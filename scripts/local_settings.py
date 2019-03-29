# RENAME THIS FILE TO local_settings.py IF YOU NEED TO CUSTOMIZE SOME SETTINGS
# BUT DO NOT COMMIT

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'radius',
        'USER': 'debug',
        'PASSWORD': 'debug',
        'HOST': 'postgres',
        'PORT': '5432',
        'OPTIONS': {'sslmode': 'require'},
    },
}

ALLOWED_HOSTS = ['*']
