using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Npgsql;

namespace StationRec
{
    public partial class StationRec : Form
    {
        public StationRec()
        {
            InitializeComponent();
        }

        private void StationRec_Load(object sender, EventArgs e)
        {
            
        }

        // инструктор
        private void button1_Click(object sender, EventArgs e)
        {
            Form newfrm1 = new Вход(1);
            if (newfrm1.ShowDialog() == DialogResult.OK)
            {
                Form newfrm2 = new Единицы();
                newfrm2.ShowDialog();
            }
        }

        // кассир
        private void button2_Click(object sender, EventArgs e)
        {
            Form newfrm1 = new Вход(2);
            if (newfrm1.ShowDialog() == DialogResult.OK)
            {
                Form newfrm2 = new Квитанции();
                newfrm2.ShowDialog();
            }
        }

        // клиент
        private void button3_Click(object sender, EventArgs e)
        {
            Form newfrm2 = new Клиент();
            newfrm2.ShowDialog();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            DataWork.end();
            Close();
        }
    }
}
