import sql, { ConnectionPool, IRecordSet, Request } from 'mssql';
import { config } from '@/config';

let pool: ConnectionPool;

const getPool = async (): Promise<ConnectionPool> => {
  if (pool && pool.connected) {
    return pool;
  }
  try {
    pool = new ConnectionPool(config.database);
    await pool.connect();
    console.log('Database connection pool created successfully.');
    pool.on('error', (err) => {
      console.error('Database Pool Error:', err);
    });
    return pool;
  } catch (err) {
    console.error('Database connection failed:', err);
    throw new Error('Failed to connect to the database.');
  }
};

export enum ExpectedReturn {
  Single,
  Multi,
  None,
}

/**
 * @summary Executes a stored procedure against the SQL Server database.
 * @param routine The name of the stored procedure to execute (e.g., '[schema].[spName]').
 * @param parameters An object containing the parameters for the stored procedure.
 * @param expectedReturn Specifies the expected return type (Single, Multi, None).
 * @returns The result from the stored procedure based on expectedReturn.
 */
export const dbRequest = async <T>(
  routine: string,
  parameters: Record<string, any>,
  expectedReturn: ExpectedReturn
): Promise<T | IRecordSet<T>[] | null> => {
  try {
    const dbPool = await getPool();
    const request: Request = dbPool.request();

    for (const key in parameters) {
      if (Object.prototype.hasOwnProperty.call(parameters, key)) {
        request.input(key, parameters[key]);
      }
    }

    const result = await request.execute(routine);

    switch (expectedReturn) {
      case ExpectedReturn.Single:
        return result.recordset && result.recordset.length > 0 ? (result.recordset[0] as T) : null;
      case ExpectedReturn.Multi:
        return result.recordsets as IRecordSet<T>[];
      case ExpectedReturn.None:
        return null;
      default:
        return result.recordsets as IRecordSet<T>[];
    }
  } catch (error) {
    console.error(`Error executing stored procedure ${routine}:`, error);
    // Re-throw a more specific error to be handled by the service layer
    throw error;
  }
};
