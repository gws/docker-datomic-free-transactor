#!/bin/sh

set -eu

host="${DATOMIC_HOST:-0.0.0.0}"
alt_host="${DATOMIC_ALT_HOST:-localhost}"
storage_admin_password="${DATOMIC_STORAGE_ADMIN_PASSWORD:-admin}"
old_storage_admin_password="${DATOMIC_OLD_STORAGE_ADMIN_PASSWORD:-}"
storage_datomic_password="${DATOMIC_STORAGE_DATOMIC_PASSWORD:-datomic}"
old_storage_datomic_password="${DATOMIC_OLD_STORAGE_DATOMIC_PASSWORD:-}"
no_chown_data="${DATOMIC_NO_CHOWN_DATA:-}"

memory_limit_bytes=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)

if [ "${memory_limit_bytes}" -ge "4294967296" ]; then
  # 4GiB limit
  memory_index_max="512m"
  object_cache_max="2g"
  heap_size_args="-Xms3968m -Xmx3968m"
elif [ "${memory_limit_bytes}" -ge "2147483648" ]; then
  # 2GiB limit
  memory_index_max="256m"
  object_cache_max="1g"
  heap_size_args="-Xms1920m -Xmx1920m"
elif [ "${memory_limit_bytes}" -ge "1073741824" ]; then
  # 1GiB limit
  memory_index_max="128m"
  object_cache_max="512m"
  heap_size_args="-Xms896m -Xmx896m"
else
  # 512MiB limit
  memory_index_max="32m"
  object_cache_max="256m"
  heap_size_args="-Xms448m -Xmx448m"
fi

sed -i "s/^\\(host\\)=.*/\\1=${host}/; \
        s/^\\(alt-host\\)=.*/\\1=${alt_host}/; \
        s/^\\(memory-index-max\\)=.*/\\1=${memory_index_max}/; \
        s/^\\(object-cache-max\\)=.*/\\1=${object_cache_max}/; \
        s/^#\\s*\\(storage-admin-password\\)=.*/\\1=${storage_admin_password}/; \
        s/^#\\s*\\(storage-datomic-password\\)=.*/\\1=${storage_datomic_password}/; \
        s/^#\\s*\\(storage-access\\)=.*/\\1=remote/" \
    /srv/datomic/config/transactor.properties

if [ -n "${old_storage_admin_password}" ]; then
  sed -i "s/^#\\s*\\(old-storage-admin-password\\)=.*/\\1=${old_storage_admin_password}/" \
    /srv/datomic/config/transactor.properties
fi

if [ -n "${old_storage_datomic_password}" ]; then
  sed -i "s/^#\\s*\\(old-storage-datomic-password\\)=.*/\\1=${old_storage_datomic_password}/" \
    /srv/datomic/config/transactor.properties
fi

if [ -z "${no_chown_data}" ]; then
  echo "Recursively changing ownership of /srv/datomic/data to datomic:datomic."
  chown -R datomic:datomic /srv/datomic/data
else
  echo "DATOMIC_NO_CHOWN_DATA set; not changing /srv/datomic/data ownership."
fi

# shellcheck disable=SC2086
exec gosu datomic /srv/datomic/bin/transactor ${heap_size_args} "$@"
