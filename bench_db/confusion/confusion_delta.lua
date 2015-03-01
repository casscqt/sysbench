pathtest = string.match(test, "(.*/)") or ""
path=string.sub(pathtest,-1,1) or ""

dofile(path .. "common_delta.lua")
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
   local i
   local a
   local query
   table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)
   local c_val
   local pad_val
   local rs
    if not oltp_skip_trx then
      db_query(begin_query)
   end
   i = sb_rand_uniform(1,oltp_table_size)
   c_val = sb_rand_str([[###########-###########-###########-###########-###########-###########-###########-###########-###########-###########]])
   pad_val = sb_rand_str([[###########-###########-###########-###########-###########]])
   T1 = {}
   T1 ={"DELETE FROM " .. table_name .. " WHERE id= ".. i,
	"INSERT INTO " .. table_name ..  " ( k, c, pad) VALUES " .. string.format("(%d, %s, %s)", sb_rand(1, oltp_table_size) , c_val, pad_val),
	"INSERT INTO " .. table_name ..  " ( k, c, pad) VALUES " .. string.format("(%d, %s, %s)", sb_rand(1, oltp_table_size) , c_val, pad_val),
	"UPDATE " .. table_name .. " SET k=k+1 WHERE id=" ..sb_rand(1, oltp_table_size),
	"UPDATE " .. table_name .. " SET k=k+1 WHERE id=" .. sb_rand(1, oltp_table_size),
	"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size),
	"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size),
	"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size),
	"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size)}
       
   b = sb_rand(1,9)
   rs=db_query(T1[b])
  if not oltp_skip_trx then
      db_query(commit_query)
   end
end

