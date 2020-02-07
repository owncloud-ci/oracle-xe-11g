def main(ctx):
  versions = [
    'latest',
  ]

  arches = [
    'amd64',
  ]

  config = {
    'version': None,
    'arch': None,
  }

  stages = []

  for version in versions:
    config['version'] = version

    if config['version'] == 'latest':
      config['path'] = 'latest'
    else:
      config['path'] = 'v%s' % config['version']

    m = manifest(config)
    inner = []

    for arch in arches:
      config['arch'] = arch

      if config['version'] == 'latest':
        config['tag'] = arch
      else:
        config['tag'] = '%s-%s' % (config['version'], arch)

      if config['arch'] == 'amd64':
        config['platform'] = 'amd64'

      if config['arch'] == 'arm64v8':
        config['platform'] = 'arm64'

      if config['arch'] == 'arm32v7':
        config['platform'] = 'arm'

      config['internal'] = '%s-%s' % (ctx.build.commit, config['tag'])

      d = docker(config)
      m['depends_on'].append(d['name'])

      inner.append(d)

    inner.append(m)
    stages.extend(inner)

  after = [
    rocketchat(config),
  ]

  for s in stages:
    for a in after:
      a['depends_on'].append(s['name'])

  return stages + after

def docker(config):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': '%s-%s' % (config['arch'], config['path']),
    'platform': {
      'os': 'linux',
      'arch': config['platform'],
    },
    'steps': steps(config),
    'volumes': volumes(config),
    'image_pull_secrets': [
      'registries',
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/pull/**',
      ],
    },
  }

def manifest(config):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'manifest-%s' % config['path'],
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'manifest',
        'image': 'plugins/manifest',
        'settings': {
          'username': {
            'from_secret': 'public_username',
          },
          'password': {
            'from_secret': 'public_password',
          },
          'spec': '%s/manifest.tmpl' % config['path'],
          'ignore_missing': 'true',
        },
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
    },
  }

def rocketchat(config):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'rocketchat',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'clone': {
      'disable': True,
    },
    'steps': [
      {
        'name': 'notify',
        'image': 'plugins/slack',
        'failure': 'ignore',
        'settings': {
          'webhook': {
            'from_secret': 'private_rocketchat',
          },
          'channel': 'builds',
        },
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
      'status': [
        'success',
        'failure',
      ],
    },
  }

def prepublish(config):
  return [{
    'name': 'prepublish',
    'image': 'plugins/docker',
    'settings': {
      'username': {
        'from_secret': 'internal_username',
      },
      'password': {
        'from_secret': 'internal_password',
      },
      'tags': config['internal'],
      'dockerfile': '%s/Dockerfile.%s' % (config['path'], config['arch']),
      'repo': 'registry.drone.owncloud.com/owncloudci/oracle-xe',
      'registry': 'registry.drone.owncloud.com',
      'context': config['path'],
      'purge': False,
    },
    'volumes': [
      {
        'name': 'docker',
        'path': '/var/lib/docker',
      },
    ],
  }]

def sleep(config):
  return [{
    'name': 'sleep',
    'image': 'toolhippie/reg:latest',
    'environment': {
      'DOCKER_USER': {
        'from_secret': 'internal_username',
      },
      'DOCKER_PASSWORD': {
        'from_secret': 'internal_password',
      },
    },
    'commands': [
      'retry -- reg digest --username $DOCKER_USER --password $DOCKER_PASSWORD registry.drone.owncloud.com/owncloudci/oracle-xe:%s' % config['internal'],
    ],
  }]

def trivy(config):
  if config['arch'] != 'amd64':
    return []

  return [
    {
      'name': 'database',
      'image': 'plugins/download',
      'settings': {
        'source': 'https://download.owncloud.com/internal/trivy.db',
        'destination': 'trivy/db/trivy.db',
        'username': {
          'from_secret': 'download_username',
        },
        'password': {
          'from_secret': 'download_password',
        },
      },
    },
    {
      'name': 'trivy',
      'image': 'toolhippie/trivy:latest',
      'environment': {
        'TRIVY_AUTH_URL': 'https://registry.drone.owncloud.com',
        'TRIVY_USERNAME': {
          'from_secret': 'internal_username',
        },
        'TRIVY_PASSWORD': {
          'from_secret': 'internal_password',
        },
        'TRIVY_SKIP_UPDATE': True,
        'TRIVY_NO_PROGRESS': True,
        'TRIVY_IGNORE_UNFIXED': True,
        'TRIVY_TIMEOUT': '5m',
        'TRIVY_EXIT_CODE': '1',
        'TRIVY_SEVERITY': 'HIGH,CRITICAL',
        'TRIVY_CACHE_DIR': '/drone/src/trivy'
      },
      'commands': [
        'retry -- trivy registry.drone.owncloud.com/owncloudci/oracle-xe:%s' % config['internal'],
      ],
    },
  ]

def publish(config):
  return [{
    'name': 'publish',
    'image': 'plugins/docker',
    'settings': {
      'username': {
        'from_secret': 'public_username',
      },
      'password': {
        'from_secret': 'public_password',
      },
      'tags': config['tag'],
      'dockerfile': '%s/Dockerfile.%s' % (config['path'], config['arch']),
      'repo': 'owncloudci/oracle-xe',
      'context': config['path'],
      'pull_image': False,
    },
    'volumes': [
      {
        'name': 'docker',
        'path': '/var/lib/docker',
      },
    ],
    'when': {
      'ref': [
        'refs/heads/master',
      ],
    },
  }]

def cleanup(config):
  return [{
    'name': 'cleanup',
    'image': 'toolhippie/reg:latest',
    'failure': 'ignore',
    'environment': {
      'DOCKER_USER': {
        'from_secret': 'internal_username',
      },
      'DOCKER_PASSWORD': {
        'from_secret': 'internal_password',
      },
    },
    'commands': [
      'reg rm --username $DOCKER_USER --password $DOCKER_PASSWORD registry.drone.owncloud.com/owncloudci/oracle-xe:%s' % config['internal'],
    ],
    'when': {
      'status': [
        'success',
        'failure',
      ],
    },
  }]

def volumes(config):
  return [
    {
      'name': 'docker',
      'temp': {},
    },
  ]

def steps(config):
  return prepublish(config) + sleep(config) + trivy(config) + publish(config) + cleanup(config)
