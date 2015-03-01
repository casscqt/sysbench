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
   local rs
   local i
   local table_name
   local range_start
   local c_val
   local pad_val
   local query

   table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)
   if not oltp_skip_trx then
      db_query(begin_query)
   end

   for i=1, oltp_point_selects do
      rs = db_query("SELECT c FROM ".. table_name .." WHERE id=" .. sb_rand(1, oltp_table_size))
   end

   for i=1, oltp_simple_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT c FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1)
   end
  
   for i=1, oltp_sum_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT SUM(K) FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1)
   end
   
   for i=1, oltp_order_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT c FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1 .. " ORDER BY c")
   end

   for i=1, oltp_distinct_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT DISTINCT c FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1 .. " ORDER BY c")
   end

   if not oltp_read_only then

   for i=1, oltp_index_updates do
      rs = db_query("UPDATE " .. table_name .. " SET k=k+1 WHERE id=" .. sb_rand(1, oltp_table_size))
   end

   for i=1, oltp_non_index_updates do
      c_val = sb_rand_str("###########-###########-###########-###########-###########-###########-###########-###########-###########-###########")
      query = "UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size)
      rs = db_query(query)
      if rs then
        print(query)
      end
   end

   i = sb_rand(1, oltp_table_size)

   rs = db_query("DELETE FROM " .. table_name .. " WHERE id=" .. i)
   
   c_val = sb_rand_str([[
###########-###########-###########-###########-###########-###########-###########-###########-###########-###########]])
   pad_val = sb_rand_str([[
###########-###########-###########-###########-###########]])

   rs = db_query("INSERT INTO " .. table_name ..  " (id, k, c, pad) VALUES " .. string.format("(%d, %d, '%s', '%s')",i, sb_rand(1, oltp_table_size) , c_val, pad_val))

   end -- oltp_read_only

   if not oltp_skip_trx then
      db_query(commit_query)
   end

end

function set_vars()
   oltp_table_size = oltp_table_size or 10000
   oltp_range_size = oltp_range_size or 100
   oltp_tables_count = oltp_tables_count or 1
   oltp_point_selects = oltp_point_selects or 10
   oltp_simple_ranges = oltp_simple_ranges or 1
   oltp_sum_ranges = oltp_sum_ranges or 1
   oltp_order_ranges = oltp_order_ranges or 1
   oltp_distinct_ranges = oltp_distinct_ranges or 1
   oltp_index_updates = oltp_index_updates or 1
   oltp_non_index_updates = oltp_non_index_updates or 1

   if (oltp_auto_inc == 'off') then
      oltp_auto_inc = false
   else
      oltp_auto_inc = true
   end

   if (oltp_read_only == 'on') then
      oltp_read_only = true
   else
      oltp_read_only = false
   end

   if (oltp_skip_trx == 'on') then
      oltp_skip_trx = true
   else
      oltp_skip_trx = false
   end

end
