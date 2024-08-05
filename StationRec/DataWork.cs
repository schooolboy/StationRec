using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Npgsql;

namespace StationRec
{

    public static class DataWork
    {
        static NpgsqlConnection conn; // подключение
        static NpgsqlCommand comm1;
        static NpgsqlCommand comm2;

        public static NpgsqlConnection get_conn() {
            return conn;
        }
        public static void connection(int type, string pass)
        {
            // инструктор 1111
            if (type == 1)
            {
                conn = new NpgsqlConnection("server = 127.0.0.1; port = 5432; database = postgres; uid = instructor; PWD = " + pass + "; IncludeErrorDetail = true");
                conn.Open();
            }
            // кассир  2222
            else if (type == 2)
            {
                conn = new NpgsqlConnection("server = 127.0.0.1; port = 5432; database = postgres; uid = cashier; PWD = " + pass + "; IncludeErrorDetail = true");
                conn.Open();
            }
            // клиент 3333
            else
            {
                conn = new NpgsqlConnection("server = 127.0.0.1; port = 5432; database = postgres; uid = client; PWD = 3333; IncludeErrorDetail = true");
                conn.Open();
            }
        }
        public static void end()
        {
            try
            {
                conn.Dispose();
                conn.Close();
            }
            catch (Exception ex) {
                return;
            }
        }

        // выборка данных
        public static DataTable read1(string s) {
            comm1 = new NpgsqlCommand(s, conn);
            comm1.CommandType = CommandType.Text;
            NpgsqlDataReader reader = comm1.ExecuteReader();
            comm1.Dispose();
            DataTable table = new DataTable();
            table.Load(reader);
            for (int i = 0; i < table.Columns.Count; i++) {
                table.Columns[i].ColumnName = table.Columns[i].ColumnName.Replace("_", " ");
            }
            reader.Close();
            return table;
        }

        // заполение таблицы
        public static void fill_table(string s, DataGridView dgv)
        {
            //object[] arr = new object[dgv.Columns.Count];
            comm1 = new NpgsqlCommand(s, conn);
            comm1.CommandType = CommandType.Text;
            NpgsqlDataReader reader = comm1.ExecuteReader();
            while (reader.Read()) {
                /*for (int i = 0; i < dgv.Columns.Count; i++) { 
                    arr[i] = reader.GetString(i);
                }*/
                dgv.Rows.Add(reader.GetString(0), reader.GetString(1), reader.GetString(2), reader.GetDouble(3), reader.GetDouble(4), reader.GetInt32(5), reader.GetInt32(6));
            }
            reader.Close();
            comm1.Dispose();
        }

        // выполнение процедуры
        public static bool exec1(int type, string table, string[] obj, string[] vartypes)
        {
            bool res = false;
            try
            {
                string message;
                switch (type) {
                    case 1: // процедура на добавление
                        comm1 = new NpgsqlCommand("add_" + table, conn);
                        message = "Запись добавлена";
                        break;
                    case 2: // процедура на обновление
                        comm1 = new NpgsqlCommand("upd_" + table, conn);
                        message = "Запись обновлена";
                        break;
                    case 3: // процедура на удаление
                        comm1 = new NpgsqlCommand("del_" + table, conn);
                        message = "Запись удалена";
                        break;
                    case 4: // другая процедура
                        comm1 = new NpgsqlCommand(table, conn);
                        message = "Запрос выполнен";
                        break;
                    default:
                        throw new Exception("Неизвестная процедура (DataWork)");
                }
                comm1.CommandType = CommandType.StoredProcedure;
                // передача параметров
                for (int i = 0; i < obj.Length; i++)
                {
                    if (vartypes[i] == "Numeric" || vartypes[i] == "Integer")
                    {
                        comm1.Parameters.AddWithValue(npgType(vartypes[i]), double.Parse(obj[i]));
                    }
                    else if (vartypes[i] == "Boolean")
                    {
                        comm1.Parameters.AddWithValue(npgType(vartypes[i]), Boolean.Parse(obj[i]));
                    }
                    else {
                        comm1.Parameters.AddWithValue(npgType(vartypes[i]), obj[i]);
                    }
                }

                // выполнение
                comm1.ExecuteNonQuery();
                MessageBox.Show(message);
                res = true;
                /*if (comm1.ExecuteNonQuery() != -1) MessageBox.Show(res);
                else MessageBox.Show("Запись не найдена");*/
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally {
                comm1.Dispose();
            }
            return res;
        }

        // определяет тип NpgsqlTypes 
        public static NpgsqlTypes.NpgsqlDbType npgType(string s) {
            switch (s) {
                case "Integer":
                    return NpgsqlTypes.NpgsqlDbType.Integer;
                case "Numeric":
                    return NpgsqlTypes.NpgsqlDbType.Numeric;
                case "Text":
                    return NpgsqlTypes.NpgsqlDbType.Text;
                case "Boolean":
                    return NpgsqlTypes.NpgsqlDbType.Boolean;
                case "Date":
                    return NpgsqlTypes.NpgsqlDbType.Date;
                case "Time":
                    return NpgsqlTypes.NpgsqlDbType.Time;
                default:
                    throw new Exception("Неизвестный тип (DataWork)");
            }
        }
    }
}
