# logfile cache with postgresql database

  ├── omd
  └── db container

The in container test in `t/local/` is a link to the mysql scenario
(`../logfile_cache_http/t/local/logcache.t`) so both scenarios run the same
suite. A relative link is used so editors on the checkout can open it, and
`docker-compose.yml` mounts that target to `/logfile_cache_http/t/local`
so the link also resolves inside the container.
