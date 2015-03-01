pathtest = string.match(test, "(.*/)") or ""

dofile(pathtest .. "my_common.lua")

function thread_init(thread_id)
   set_vars()
end

function event(thread_id)
   local i
   local query
   table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)
   local c_val
   local pad_val
   local rs
   T1 = {}
   T1 ={"DELETE FROM " .. table_name .. " WHERE id= ".. i,"INSERT INTO " .. table_name ..  " (id, k, c, pad) VALUES " .. string.format("(%d, %d, %s, %s)",i, sb_rand(1, oltp_table_size) , c_val, pad_val),"INSERT INTO " .. table_name ..  " (id, k, c, pad) VALUES " .. string.format("(%d, %d, %s, %s)",i, sb_rand(1, oltp_table_size) , c_val, pad_val),"UPDATE " .. table_name .. " SET k=k+1 WHERE id=" .. sb_rand(1, oltp_table_size),"UPDATE " .. table_name .. " SET k=k+1 WHERE id=" .. sb_rand(1, oltp_table_size),"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size),"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size),"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size),"UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size)}

   for a=1,oltp_table_size do
      b = sb_rand(1,9)
      i = sb_rand(1,oltp_table_size)
      if b~=1 then
	c_val = sb_rand_str([[###########-###########-###########-###########-###########-###########-###########-###########-###########-###########]])
        pad_val = sb_rand_str([[###########-###########-###########-###########-###########]])
      end
        rs=db_query(T1[b])
   end
end
