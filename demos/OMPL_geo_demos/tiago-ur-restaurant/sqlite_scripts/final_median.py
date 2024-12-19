import sqlite3

def extract_median_and_weighted_sum(db_file, table_name):
    try:
        # Connect to the SQLite database
        conn = sqlite3.connect(db_file)
        cursor = conn.cursor()

        # SQL query for median and weighted sum
        query = f"""
        WITH OrderedTime AS (
            SELECT 
                plannerid, 
                time,
                ROW_NUMBER() OVER (PARTITION BY plannerid ORDER BY time) AS row_num,
                COUNT(*) OVER (PARTITION BY plannerid) AS total_rows
            FROM {table_name}
        ),
        MedianTime AS (
            SELECT 
                plannerid, 
                AVG(time) AS median_time
            FROM OrderedTime
            WHERE row_num IN ( (total_rows + 1) / 2, (total_rows + 2) / 2 )
            GROUP BY plannerid
        ),
        OrderedSolutionLength AS (
            SELECT 
                plannerid, 
                solution_length,
                ROW_NUMBER() OVER (PARTITION BY plannerid ORDER BY solution_length) AS row_num,
                COUNT(*) OVER (PARTITION BY plannerid) AS total_rows
            FROM {table_name}
        ),
        MedianSolutionLength AS (
            SELECT 
                plannerid, 
                AVG(solution_length) AS median_solution_length
            FROM OrderedSolutionLength
            WHERE row_num IN ( (total_rows + 1) / 2, (total_rows + 2) / 2 )
            GROUP BY plannerid
        )
        SELECT 
            mt.plannerid,
            mt.median_time,
            ms.median_solution_length,
            (0.5 * mt.median_time + 0.5 * ms.median_solution_length) AS weighted_sum
        FROM 
            MedianTime mt
        JOIN 
            MedianSolutionLength ms
        ON 
            mt.plannerid = ms.plannerid;
        """

        # Execute the query
        cursor.execute(query)
        results = cursor.fetchall()

        # Print the results
        print(f"Medians and Weighted Sum for each plannerid in table '{table_name}':")
        print("-" * 70)
        print(f"{'PlannerID':<15}{'Median Time':<15}{'Median Solution Length':<20}{'Weighted Sum':<15}")
        print("-" * 70)
        for row in results:
            print(f"{row[0]:<15}{row[1]:<15.2f}{row[2]:<20.2f}{row[3]:<15.2f}")

        # Close the connection
        conn.close()

    except sqlite3.Error as e:
        print(f"SQLite error: {e}")
    except Exception as e:
        print(f"General error: {e}")
        
db_file ="result_Pick_RRT_Range.db"
table_name = "runs"  
extract_median_and_weighted_sum(db_file, table_name)
