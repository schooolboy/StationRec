using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace StationRec
{
    public partial class Новая_квитанция : Form
    {
        object value1;
        object value2;
        string id;
        public Новая_квитанция(string id)
        {
            this.id = id;
            value1 = null;
            value2 = null;
            InitializeComponent();
            dataGridView1.Columns.Add("Column1", "инвентарный номер");
            dataGridView1.Columns.Add("Column2", "наименование модели");
            dataGridView1.Columns.Add("Column3", "категория");
            dataGridView1.Columns.Add("Column4", "стоимость аренды");
            dataGridView1.Columns.Add("Column5", "стоимость залога");
            dataGridView1.Columns.Add("Column6", "максимальная скорость");
            dataGridView1.Columns.Add("Column7", "число мест");
            dataGridView2.Columns.Add("Column1", "инвентарный номер");
            dataGridView2.Columns.Add("Column2", "наименование модели");
            dataGridView2.Columns.Add("Column3", "категория");
            dataGridView2.Columns.Add("Column4", "стоимость аренды");
            dataGridView2.Columns.Add("Column5", "стоимость залога");
            dataGridView2.Columns.Add("Column6", "максимальная скорость");
            dataGridView2.Columns.Add("Column7", "число мест");
            dataGridView1.Columns[0].Visible = false;
            dataGridView2.Columns[0].Visible = false;
            init();
        }

        // выход
        private void button4_Click(object sender, EventArgs e)
        {
            Close();
        }

        // добавить
        private void button1_Click(object sender, EventArgs e)
        {
            if (value1 == null)
            {
                MessageBox.Show("Необходимо выбрать единицу");
            }
            else {
                //table2.ImportRow(table1.Rows[(int)value1]);
                //table1.Rows.RemoveAt((int) value1);
                DataGridViewRow r = dataGridView1.Rows[(int)value1];
                dataGridView1.Rows.RemoveAt((int)value1);
                dataGridView2.Rows.Add(r);
                value1 = null;
            }
        }

        // убрать
        private void button2_Click(object sender, EventArgs e)
        {
            if (value2 == null)
            {
                MessageBox.Show("Необходимо выбрать единицу");
            }
            else {
                //table1.ImportRow(table2.Rows[(int)value2]);
                //table2.Rows.RemoveAt((int)value2);
                DataGridViewRow r = dataGridView2.Rows[(int)value2];
                dataGridView2.Rows.RemoveAt((int) value2);
                dataGridView1.Rows.Add(r);
                value2 = null;
            }
        }

        // оплата
        private void button3_Click(object sender, EventArgs e)
        {
            if (textBox1.Text == "") {
                MessageBox.Show("Поле длительность должно быть заполнено. Формат - HH:MM");
                return;
            }
            if (dataGridView2.Rows.Count < 1) {
                MessageBox.Show("Число арендуемых единиц должно быть не меньше 1");
                return;
            }
            this.DialogResult = DialogResult.OK;
            using (var tx = DataWork.get_conn().BeginTransaction())
            {
                if (!DataWork.exec1(4, "proc_оплата", new string[] { id, buildParams(), textBox1.Text }, new string[] { "Integer", "Text", "Text" })) this.DialogResult = DialogResult.None;
                tx.Commit();
            }
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;
            value1 = e.RowIndex;
        }

        private void dataGridView2_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;
            value2 = e.RowIndex;
        }

        // обновить единицы базы
        private void init()
        {
            //table1 = DataWork.read1("select * from единица");
            //table1.Columns.RemoveAt(3);
            //table1.Columns.RemoveAt(2);
            //DataWork.fill_table("select * from единица where арендована = false and пригодность = true", dataGridView1);
            DataWork.fill_table("select * from доступные_единицы", dataGridView1);
/*            dataGridView1.DataSource = table1;
            table2 = table1.Clone();
            table2.Rows.Clear();
            dataGridView2.DataSource = table2;*/
        }

        private string buildParams()
        {
            int i;
            string s = "";
            for (i = 0; i < dataGridView2.RowCount - 1; i++)
            {
                s += dataGridView2.Rows[i].Cells[0].Value +  ",";
            }
            s += dataGridView2.Rows[i].Cells[0].Value;
            return s;
        }

    }
}
