pathtest = string.match(test, "(.*/)") or ""
path=string.sub(pathtest,-1,1) or ""

dofile(path .. "common.lua")
function thread_init(thread_id)
   set_vars()
   if (db_driver == "mysql" and mysql_table_engine == "myisam") then
      begin_query = "LOCK TABLES sbtest WRITE"
      commit_query = "UNLOCK TABLES"
   else
      begin_query = "BEGIN"
      commit_query = "COMMIT"
   end
end

function event(thread_id)
   local table_name
   local c_val
   local query
   table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)
   if not oltp_skip_trx then
      db_query(begin_query)
   end
   c_val = sb_rand_str("###########-###########-###########-###########-###########-###########-###########-###########-###########-###########")
   query = "UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE k=" .. sb_rand(1, oltp_table_size)
   rs = db_query(query)
   if not oltp_skip_trx then
      db_query(commit_query)
   end
end
