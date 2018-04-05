jenkins group:
  group.present:
    - name: jenkins
    - gid: 1000

jenkins user:
  user.present:
    - name: jenkins
    - uid: 1000
    - gid: 1000
    - require:
      - jenkins group

{{ salt['pillar.get']('data_path') }}/jenkins_home/:
  file.directory:
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True
    - require:
      - jenkins user

docker_jenkins:
  docker_container.running:
    - name: jenkins
    - image: jenkinsci/blueocean
    - binds: {{ salt['pillar.get']('data_path') }}/jenkins_home:/var/jenkins_home
    - networks:
      - docker_internal_network
    - require:
      - pip install docker
      - docker_internal_network