cd /cartodb
source /usr/local/rvm/scripts/rvm

echo "INSERT INTO feature_flags (id,name, restricted) VALUES (nextval('machine_added_feature_flags_id_seq'), 'editor-3', false);" | psql -U postgres carto_db_development && \
echo "INSERT INTO feature_flags (id,name, restricted) VALUES (nextval('machine_added_feature_flags_id_seq'), 'explore_site', false);" | psql -U postgres carto_db_development && \

ORGANIZATION_NAME="example"
USERNAME="admin4example"
EMAIL="admin@example.com"
PASSWORD="pass1234"

bundle exec rake cartodb:db:create_user EMAIL="${EMAIL}" PASSWORD="${PASSWORD}" SUBDOMAIN="${USERNAME}"
bundle exec rake cartodb:db:set_unlimited_table_quota["${USERNAME}"]
bundle exec rake cartodb:db:create_new_organization_with_owner ORGANIZATION_NAME="${ORGANIZATION_NAME}" USERNAME="${USERNAME}" ORGANIZATION_SEATS=100 ORGANIZATION_QUOTA=102400 ORGANIZATION_DISPLAY_NAME="${ORGANIZATION_NAME}"
bundle exec rake cartodb:db:set_organization_quota[$ORGANIZATION_NAME,100]
