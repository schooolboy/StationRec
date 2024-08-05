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
    // класс универсальной формы ввода данных. Конструктор заполняет форму полями ввода используя массивы-параметры. Далее введеные значения передаются на вход функции exe1 вместе с переданным видом операции и таблицей(процедурой)
    public partial class Ввод_данных : Form
    {
        TextBox[] obj_controls;
        Label[] obj_fields;
        string[] vartypes;
        int type;
        string table;
        public Ввод_данных(int type, string table, string operation_description, object[] obj_field, string[] vartypes, int index = -1, object key = null)
        {
            InitializeComponent();
            this.vartypes = vartypes;
            this.type = type;
            this.table = table;
            label1.Text = operation_description;
            Point currentLocation = label1.Location;
            this.Controls.Remove(label2);
            this.Controls.Remove(textBox1);
            obj_controls = new TextBox[obj_field.Length];
            obj_fields = new Label[obj_field.Length];
            currentLocation.Y += 10;
            for (int i = 0; i < obj_field.Length; i++) {
                obj_fields[i] = new Label();
                obj_controls[i] = new TextBox();
                obj_fields[i].Text = obj_field[i].ToString() + " :";
                obj_fields[i].AutoSize = true;
                obj_controls[i].Width = 140;
                obj_fields[i].Location = new Point(15, currentLocation.Y + 20);
                obj_controls[i].Location = new Point(180, currentLocation.Y + 15);
                this.Controls.Add(obj_fields[i]);
                this.Controls.Add(obj_controls[i]);
                currentLocation.Y += 30;
            }
            if (table == "клиент" && obj_fields[0].Text == "ид :") {
                obj_fields[0].Visible = false;
                obj_controls[0].Visible = false;
            }
            if (key != null) {
                obj_controls[index].Text = key.ToString();
            }
            this.Height = 110 + 30 * obj_field.Length;
            button1.Location = new Point(15, this.Height - 70);
            button2.Location = new Point(180, this.Height - 70);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
            if (!DataWork.exec1(type, table, fill_arr(), vartypes)) this.DialogResult = DialogResult.None;
        }

        private string[] fill_arr()
        {
            string[] obj = new string[obj_controls.Length];
            for (int i = 0; i < obj_controls.Length; i++) {
                if (vartypes[i] == "Boolean")
                {
                    if (obj_controls[i].Text == "да") { obj[i] = "true"; }
                    else if (obj_controls[i].Text == "нет") { obj[i] = "false"; }
                    else { obj[i] = obj_controls[i].Text; }
                }
                else {
                    obj[i] = obj_controls[i].Text;
                }
            }
            return obj;
        }
    }
}
