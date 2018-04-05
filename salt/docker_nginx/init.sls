docker_nginx:
  docker_container.running:
    - name: nginx
    - image: nginx
    - require:
      - pip install docker
      - docker_internal_network