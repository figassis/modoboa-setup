clear
# docker-compose down -v; docker-compose build && docker-compose up -d --force-recreate
docker-compose down --remove-orphans; docker-compose up -d --force-recreate
