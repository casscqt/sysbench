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
   local i
   local c_val
   local k_val
   local pad_val

   table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)
   
   if not oltp_skip_trx then
      db_query(begin_query)
   end
   
   k_val = sb_rand(1, oltp_table_size)
   c_val = sb_rand_str([[
###########-###########-###########-###########-###########-###########-###########-###########-###########-###########]])
   pad_val = sb_rand_str([[
###########-###########-###########-###########-###########]])
   
   rs = db_query("INSERT INTO " .. table_name ..  " (k, c, pad) VALUES " .. string.format("(%d, '%s', '%s')", k_val, c_val, pad_val))
   if not oltp_skip_trx then
      db_query(commit_query)
   end
end
