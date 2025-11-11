load('ext://dotenv', 'dotenv')
load('ext://namespace', 'namespace_create')
load('ext://helm_resource', 'helm_resource', 'helm_repo')

dotenv()

namespace_create('matrix-stack')

helm_resource(
    'ingress-nginx',
    'ingress-nginx',
    flags=['--repo', 'https://kubernetes.github.io/ingress-nginx', '--create-namespace'],
    namespace='ingress-nginx',
)

helm_resource(
    'cloudnative-pg',
    'cloudnative-pg',
    flags=['--repo', 'https://cloudnative-pg.github.io/charts', '--create-namespace'],
    namespace='cnpg-system',
)
k8s_kind('Cluster', api_version='postgres.cnpg.io/v1', image_json_path='{.spec.imageName}', pod_readiness='wait')

k8s_yaml('./dev/postgres.yaml')
k8s_resource(
    new_name='postgres-synapse',
    objects=['postgres-synapse'],
    resource_deps=['cloudnative-pg'],
)

k8s_yaml(helm(
    './charts/matrix-stack',
    name='matrix-stack',
    namespace='matrix-stack',
    values=['./charts/matrix-stack/values-dev.yaml'],
))

k8s_resource(
    'matrix-stack-synapse',
    new_name='synapse',
    objects=[
        'matrix-stack-synapse:configmap',
        'matrix-stack-synapse:ingress',
        'matrix-stack-synapse-media:persistentvolumeclaim',
    ],
    resource_deps=['postgres-synapse'],
    links=[
        os.getenv('HOMESERVER_HOST'),
    ],
)
