import sqlite3

def extract_average_and_weighted_sum(db_file, table_name):
    try:
        conn = sqlite3.connect(db_file)
        cursor = conn.cursor()

        # sqlquery 
        query = f"""
        SELECT 
            plannerid, 
            AVG(time) AS average_time, 
            AVG(solution_length) AS average_solution_length,
            (0.5 * AVG(time) + 0.5 * AVG(solution_length)) AS weighted_sum
        FROM 
            {table_name}
        GROUP BY 
            plannerid;
        """

        # Execute the query
        cursor.execute(query)
        results = cursor.fetchall()

        print(f"Averages and Weighted Sum for each plannerid in table '{table_name}':")
        print("-" * 70)
        print(f"{'PlannerID':<15}{'Avg Time':<15}{'Avg Solution Length':<20}{'Weighted Sum':<15}")
        print("-" * 70)
        for row in results:
            print(f"{row[0]:<15}{row[1]:<15.2f}{row[2]:<20.2f}{row[3]:<15.2f}")

        conn.close()

    except sqlite3.Error as e:
        print(f"SQLite error: {e}")
    except Exception as e:
        print(f"General error: {e}")

#db_file = "result_Pick.db"  
db_file ="result_Pick_RRT_Range.db"
table_name = "runs"  
extract_average_and_weighted_sum(db_file, table_name)

