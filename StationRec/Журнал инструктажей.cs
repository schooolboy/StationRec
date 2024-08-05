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
    public partial class Журнал_инструктажей : Form
    {
        object value1;
        public Журнал_инструктажей()
        {
            value1 = null;
            InitializeComponent();
            init1();
            init2();
        }

        // отметить инструктаж
        private void button1_Click(object sender, EventArgs e)
        {
            /*Form newfrm = new Ввод_данных(4, "proc_инструктаж", "Запись об инструктаже", new string[] { "номер квитанции" }, new string[] { "Integer" },);
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                // ничего не нужно обновлять
            }*/
            if (value1 == null) {
                MessageBox.Show("Необходимо выбрать непроведенный инструктаж");
                return;
            }
            if (DataWork.exec1(4, "proc_инструктаж", new string[] { value1.ToString() }, new string[] { "Integer" }) != false) {
                init1();
                init2();
                value1 = null;
            }
        }

        // выход
        private void button2_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) {
                return;
            }
            value1 = dataGridView1.Rows[e.RowIndex].Cells[0].Value;
        }

        private void init1()
        {
            dataGridView1.DataSource = DataWork.read1("select * from журнал_инструктажей where пометка_инструктажа = false");
            dataGridView1.Columns["номер квитанции"].Visible = false;
            dataGridView1.Columns["пометка инструктажа"].Visible = false;
        }

        private void init2()
        {
            dataGridView2.DataSource = DataWork.read1("select * from журнал_инструктажей where пометка_инструктажа = true");
            dataGridView2.Columns["номер квитанции"].Visible = false;
            dataGridView2.Columns["пометка инструктажа"].Visible = false;
        }
    }
}
