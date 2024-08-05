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
    public partial class Квитанция : Form
    {
        object[] items;
        public Квитанция(string numcheck)
        {
            float lien = 0;
            float sum = 0;
            InitializeComponent();
            items = DataWork.read1("select * from квитанции where номер_квитанции = " + numcheck).Rows[0].ItemArray;
            this.label6.Text = items[0].ToString();
            this.label7.Text = items[1].ToString();
            this.label8.Text = items[2].ToString();
            this.label9.Text = items[4].ToString();
            DataTable data = DataWork.read1("select * from единицы_квитанции where номер_квитанции = " + numcheck);
            for (int i = 0; i < data.Rows.Count; i++) { 
                sum += float.Parse(data.Rows[i].ItemArray[4].ToString());
                if (Boolean.Parse(data.Rows[i].ItemArray[7].ToString()) == true) {
                    lien += float.Parse(data.Rows[i].ItemArray[3].ToString());
                }
            }
            dataGridView1.DataSource = data;
            dataGridView1.Columns["номер квитанции"].Visible = false;
            this.label10.Text = sum.ToString();
            int minutes = DateTime.Parse(label9.Text).Hour * 60 + DateTime.Parse(label9.Text).Minute;
            this.label12.Text = (lien * (minutes / 30)).ToString();

        }
        private void button1_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}
