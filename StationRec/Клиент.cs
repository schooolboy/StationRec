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
    public partial class Клиент : Form
    {
        public Клиент()
        {
            InitializeComponent();
            DataWork.connection(3, "");
        }

        // продолжить
        private void button1_Click(object sender, EventArgs e)
        {
            if (textBox1.Text == "") {
                MessageBox.Show("Необходимо ввести номер телефона");
                return;
            }
            object count = DataWork.read1("select count(*) from клиент where номер_телефона = \'" + textBox1.Text + "\'").Rows[0].ItemArray[0];
            if (count.ToString() != "1")
            {
                MessageBox.Show("Нет данных о таком пользователе");
                Form newfrm1 = new Ввод_данных(1, "клиент", "Введите свои данные", new string[] { "номер телефона", "фамилия", "имя", "отчество", "дата рождения" }, new string[] { "Text", "Text", "Text", "Text", "Text" }, 0, textBox1.Text);
                newfrm1.ShowDialog();
                return;
            }
            else {
                object id = DataWork.read1("select ид from клиент where номер_телефона = \'" + textBox1.Text + "\'").Rows[0].ItemArray[0];
                Form newfrm2 = new Новая_квитанция(id.ToString());
                newfrm2.ShowDialog();
            }
        }
    }
}
