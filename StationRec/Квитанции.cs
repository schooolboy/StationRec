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
    public partial class Квитанции : Form
    {
        object value1;
        object value2;
        public Квитанции()
        {
                value1 = null;
                value2 = null;
                InitializeComponent();
                init1();
                init2();
                this.dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;
                this.dataGridView2.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;
        }

        // выход
        private void button3_Click(object sender, EventArgs e)
        {
            DataWork.end();
            Close();
        }

        // добавить клиента
        private void button1_Click(object sender, EventArgs e)
        {
            Form newfrm = new Ввод_данных(1, "клиент", "Добавить клиента", new string[] { "номер телефона", "фамилия", "имя", "отчество", "дата рождения"}, new string[] { "Text", "Text", "Text", "Text", "Text"});
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                init1();
            }
        }

        // редактировать клиента
        private void button2_Click(object sender, EventArgs e)
        {
            Form newfrm = new Ввод_данных(2, "клиент", "Обновить клиента", new string[] { "ид", "номер телефона", "фамилия", "имя", "отчество"}, new string[] { "Integer", "Text", "Text", "Text", "Text", "Text" }, 0, value1);
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                init1();
            }
        }

        // новая квитанция
        private void button4_Click(object sender, EventArgs e)
        {
            if (value1 == null) {
                MessageBox.Show("Необходимо выбрать клиента");
                return;
            }
            Form newfrm = new Новая_квитанция(value1.ToString());
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                init1();
                init2();
                value1 = null;
            }
        }

        // обновить клиентов
        private void init1()
        {
            dataGridView1.DataSource = DataWork.read1("select * from клиент");
            dataGridView1.Columns["Ид"].Visible = false;
        }
        // обновить квитанции
        private void init2()
        {
            if (value1 != null)
            {
                dataGridView2.DataSource = DataWork.read1("select * from квитанции where ид_клиента = \'" + value1.ToString() + "\'");
            }
            else
            {
                dataGridView2.DataSource = DataWork.read1("select * from квитанции");
            }
            dataGridView2.Columns["ид клиента"].Visible = false;
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;
            value1 = dataGridView1.Rows[e.RowIndex].Cells[0].Value;
            value2 = null;
            init2();
        }

        private void dataGridView2_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;
            value2 = dataGridView2.Rows[e.RowIndex].Cells[0].Value;
        }

        // просмотреть подробнее квитанцию
        private void button5_Click(object sender, EventArgs e)
        {
            if (value2 == null) {
                MessageBox.Show("Необходимо выбрать квитанцию");
                return;
            }
            Form newfrm = new Квитанция(value2.ToString());
            newfrm.ShowDialog();
        }

        private void Квитанции_Load(object sender, EventArgs e)
        {
            this.dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dataGridView2.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }
    }
}
