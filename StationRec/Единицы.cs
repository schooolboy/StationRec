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
    public partial class Единицы : Form
    {
        object value1;
        object value2;
        public Единицы()
        {
            value1 = null;
            value2 = null;
            InitializeComponent();
            this.dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;
            this.dataGridView2.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;
            init1();
            init2();
        }

        // выход
        private void button9_Click(object sender, EventArgs e)
        {
            DataWork.end();
            Close();
        }

        // инструктаж
        private void button7_Click(object sender, EventArgs e)
        {
            Form newfrm = new Журнал_инструктажей();
            newfrm.ShowDialog();
        }

        // возврат
        private void button8_Click(object sender, EventArgs e)
        {
            Form newfrm = new Ввод_данных(4, "proc_возврат", "Запись о возврате единицы", new string[] { "инвентарный номер", "пригодность единицы" }, new string[] { "Text", "Boolean" }, 0, value2);
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                init2();
            }
        }

        // добавить модель единицы
        private void button1_Click(object sender, EventArgs e)
        {
            Form newfrm = new Ввод_данных(1, "модель_единицы", "Добавить модель", new string[] { "наименование", "стоимость аренды", "стоимость залога", "число мест", "максимальная скорость", "категория"}, new string[] { "Text", "Numeric", "Numeric", "Integer", "Integer", "Text" });
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                init1();
            }
        }

        // редактировать модель единицы
        private void button2_Click(object sender, EventArgs e)
        {
            Form newfrm = new Ввод_данных(2, "модель_единицы", "Изменить стоимость", new string[] { "наименование", "стоимость аренды", "стоимость залога"}, new string[] { "Text", "Numeric", "Numeric", }, 0, value1);
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                init1();
            }
        }

        // добавить единицу
        private void button4_Click(object sender, EventArgs e)
        {
            Form newfrm = new Ввод_данных(1, "единица", "Добавить единицу", new string[] { "инвентарный номер", "наименование модели"}, new string[] { "Text", "Text"}, 1, value1);
            if (newfrm.ShowDialog() == DialogResult.OK)
            {
                init2();
            }
        }

        // редактировать единицу (обновить)
        private void button5_Click(object sender, EventArgs e)
        {
            Form newfrm = new Ввод_данных(2, "единица", "Обновить единицу", new string[] { "инвентарный номер", "пригодность", "свободна" }, new string[] { "Text", "Boolean", "Boolean" }, 0, value2);
            if (newfrm.ShowDialog() == DialogResult.OK) {
                init2();
            }
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;
            value1 = dataGridView1.Rows[e.RowIndex].Cells[0].Value;
            value2 = null;
            init2();
        }

        // удалить модель единицы
        private void button3_Click(object sender, EventArgs e)
        {
            if (value1 != null)
            {
                DataWork.exec1(3, "модель_единицы", new string[] { value1.ToString() }, new string[] { "Text" });
                value1 = null;
                init1();
            }
            else {
                MessageBox.Show("Необходимо выбрать модель единицы");
            }
        }

        private void dataGridView2_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;
            value2 = dataGridView2.Rows[e.RowIndex].Cells[0].Value;
        }

        // обновить модели
        private void init1()
        {
            dataGridView1.DataSource = DataWork.read1("select * from модель_единицы");
        }
        // обновить единицы
        private void init2()
        {
            if (value1 != null)
            {
                dataGridView2.DataSource = DataWork.read1("select * from единица where наименование_модели = \'" + value1.ToString() + "\' and not(пригодность = false and арендована = true)");
            }
            else
            {
                dataGridView2.DataSource = DataWork.read1("select * from единица where not(пригодность = false and арендована = true)");
            }
        }

        // удалить единицу
        private void button6_Click(object sender, EventArgs e)
        {
            if(value2 != null)
            {
                DataWork.exec1(2, "единица", new string[] { value2.ToString(), true.ToString(), false.ToString() }, new string[] { "Text", "Boolean", "Boolean" });
                value2 = null;
                init2();
            }
            else
            {
                MessageBox.Show("Необходимо выбрать единицу");
            }
        }

        private void Единицы_Load(object sender, EventArgs e)
        {
            this.dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dataGridView2.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }
    }
}
