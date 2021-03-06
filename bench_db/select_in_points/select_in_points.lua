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

   print("Creating table 'sbtest" .. i .. "'...")
   if (db_driver == "mysql") then
      query = [[
CREATE TABLE sbtest]] .. i .. [[ (
id INTEGER UNSIGNED NOT NULL ]] ..
((oltp_auto_inc and "AUTO_INCREMENT") or "") .. [[,
k INTEGER UNSIGNED DEFAULT '0' NOT NULL,
c CHAR(120) DEFAULT '' NOT NULL,
pad CHAR(60) DEFAULT '' NOT NULL,
]] .. index_name .. [[ (id)
) /*! ENGINE = ]] .. mysql_table_engine ..
" MAX_ROWS = " .. myisam_max_rows .. " */"

   elseif (db_driver == "pgsql") then
      query = [[
CREATE TABLE sbtest]] .. i .. [[ (
id SERIAL NOT NULL,
k INTEGER DEFAULT '0' NOT NULL,
c CHAR(120) DEFAULT '' NOT NULL,
pad CHAR(60) DEFAULT '' NOT NULL,
]] .. index_name .. [[ (id)
) ]]

   elseif (db_driver == "drizzle") then
      query = [[
CREATE TABLE sbtest (
id INTEGER NOT NULL ]] .. ((oltp_auto_inc and "AUTO_INCREMENT") or "") .. [[,
k INTEGER DEFAULT '0' NOT NULL,
c CHAR(120) DEFAULT '' NOT NULL,
pad CHAR(60) DEFAULT '' NOT NULL,
]] .. index_name .. [[ (id)
) ]]
   else
      print("Unknown database driver: " .. db_driver)
      return 1
   end

   db_query(query)

   db_query("CREATE INDEX k_" .. i .. " on sbtest" .. i .. "(k)")

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
	 db_bulk_insert_next("(" .. sb_rand(1, oltp_table_size) .. ", '".. c_val .."', '" .. pad_val .. "')")
      else
	 db_bulk_insert_next("("..j.."," .. sb_rand(1, oltp_table_size) .. ",'".. c_val .."', '" .. pad_val .. "'  )")
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
   local rs

   -- To prevent overlapping of our range queries we need to partition the whole table
   -- into num_threads segments and then make each thread work with its own segment.
      
   local table_name
   table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)
   points = ""
   for i = 1,random_points do
      if (points == "") then
        points = 1+sb_rnd()%oltp_table_size
      else
        points = points .. "," .. 1+sb_rnd()%oltp_table_size
      end
   end
   rs = db_query("SELECT id,k,c,pad FROM ".. table_name .." WHERE id IN (" .. points .. ")")
end

function set_vars()
   oltp_table_size = oltp_table_size or 10000
   random_points = random_points or 10

   if (oltp_auto_inc == 'off') then
      oltp_auto_inc = false
   else
      oltp_auto_inc = true
   end
end
