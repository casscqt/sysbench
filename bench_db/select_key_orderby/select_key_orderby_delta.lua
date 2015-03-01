-- Input parameters
-- oltp-tables-count - number of tables to create
-- oltp-secondary - use secondary key instead PRIMARY key for id column
--
--

function create_insert(table_id)

   local index_name
   local i
   local j
   local query

   if (oltp_secondary) then
     index_name = "KEY xid"
   else
     index_name = "PRIMARY KEY"
   end

   i = table_id

   print("Inserting " .. oltp_table_size .. " records into 'sbtest" .. i .. "'")

   if (oltp_auto_inc) then
      db_bulk_insert_init("INSERT INTO sbtest" .. i .. "(k, c, pad) VALUES")
   else
      db_bulk_insert_init("INSERT INTO sbtest" .. i .. "(id, k, c, pad) VALUES")
   end

   local c_val
   local pad_val


   for j = 1,oltp_table_size do

   c_val = sb_rand_str([[
###########-###########-###########-###########-###########-###########-###########-###########-###########-###########]])
   pad_val = sb_rand_str([[
###########-###########-###########-###########-###########]])

      if (oltp_auto_inc) then
	 db_bulk_insert_next("(" .. 1+sb_rnd()%oltp_table_size  .. ", '".. c_val .."', '" .. pad_val .. "')")
      else
	 db_bulk_insert_next("("..j.."," .. 1+sb_rnd()%oltp_table_size  .. ",'".. c_val .."', '" .. pad_val .. "'  )")
      end
   end

   db_bulk_insert_done()


end


function prepare()
   local query
   local i
   local j

   set_vars()

   db_connect()


   for i = 1,oltp_tables_count do
     create_insert(i)
   end

   return 0
end

function cleanup()
   local i

   set_vars()

   for i = 1,oltp_tables_count do
   print("Dropping table 'sbtest" .. i .. "'...")
   db_query("DROP TABLE sbtest".. i )
   end
end

function thread_init(thread_id)
   set_vars()
end

function event(thread_id)
   local table_name 
   local a  
   local b
   a = sb_rand(oltp_table_size / num_threads * thread_id, oltp_table_size / num_threads * (thread_id + 1))
   b = a + delta
   table_name = "sbtest".. sb_rand(1,oltp_tables_count)
   rs = db_query("SELECT id,k,c,pad FROM ".. table_name .. " WHERE k= " .. sb_rand(1,oltp_table_size))
   rs = db_query("SELECT id,k,c,pad FROM ".. table_name .. " WHERE k between " .. a .. " and " .. b)
end


function set_vars()
   delta = random_ranges_delta or 5
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
