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
    public partial class Вход : Form
    {
        int type;
        public Вход(int type)
        {
            InitializeComponent();
            this.type = type;
            textBox1.PasswordChar = '*';
            this.DialogResult = DialogResult.No;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (textBox1.Text == "") {
                MessageBox.Show("Поле не должено быть пустым");
                return;
            }
            try
            {
                DataWork.connection(type, textBox1.Text);
                this.DialogResult = DialogResult.OK;
            }
            catch (Exception ex) {
                MessageBox.Show("Пароль неверный");
            }
        }
    }
}
