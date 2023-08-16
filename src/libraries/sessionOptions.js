import dbConfig from "../config/dbConfig.json";

export const sessionOptions = {
    host:dbConfig.host,
    port:dbConfig.port,
    user:dbConfig.user,
    password:dbConfig.password,
    charset: 'utf8',
    database:dbConfig.database,
    cookie: {
        SameSite:"None"
    },
    schema: {
		tableName: 'Sessions',
		columnNames: {
			session_id: 'session_id',
			expires: 'expires',
			data: 'data'
		}
	}
}