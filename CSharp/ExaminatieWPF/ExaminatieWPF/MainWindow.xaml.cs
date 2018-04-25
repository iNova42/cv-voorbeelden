using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace ExaminatieWPF
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		//Fields
		private static string kerstTag = "Bestanden/kerstkaart.jpg";
		private static string geboorteTag = "Bestanden/geboortekaart.jpg";
		public readonly ImageBrush geboorteAchtergrond = new ImageBrush(new BitmapImage(new Uri("pack://application:,,,/"+geboorteTag)));
		public readonly ImageBrush kerstAchtergrond = new ImageBrush(new BitmapImage(new Uri("pack://application:,,,/"+kerstTag)));

		//Constructor
		public MainWindow()
		{
			InitializeComponent();
			lettertypeComboBox.SelectedItem = new FontFamily("Script MT");
		}

		//Repeatbuttons
		private void Plus_Click(object sender, RoutedEventArgs e)
		{
			int aantal = Convert.ToInt16(GrootteLabel.Content);
			if (aantal < 40)
				aantal++;
			GrootteLabel.Content = aantal.ToString();
		}
		private void Min_Click(object sender, RoutedEventArgs e)
		{
			int aantal = Convert.ToInt16(GrootteLabel.Content);
			if (aantal > 10)
				aantal--;
			GrootteLabel.Content = aantal.ToString();
		}

		private void KerstkaartBg(object sender, RoutedEventArgs e)
		{
			Nieuw();
			KaartCanvas.Background = (Brush)kerstAchtergrond;
			KaartCanvas.Tag = kerstTag;
			MenuItemOpslaan.IsEnabled = true;
			MainGrid.Visibility = Visibility.Visible;
		}
		private void GeboorteKaartBg(object sender, RoutedEventArgs e)
		{
			Nieuw();
			KaartCanvas.Background = (Brush)geboorteAchtergrond;
			KaartCanvas.Tag = geboorteTag;
			MenuItemOpslaan.IsEnabled = true;
			MainGrid.Visibility = Visibility.Visible;
		}

		//Drag & Drop
		private void Ellipse_MouseMove(object sender, MouseEventArgs e)
		{
			sleepEllipse = (Ellipse)sender;
			if (e.LeftButton == MouseButtonState.Pressed)
			{
				Ellipse stuk = (Ellipse)sender;
				try
				{
					DataObject sleepKleur = new DataObject("deKleur", sleepEllipse.Fill);
					DragDrop.DoDragDrop(stuk, sleepKleur, DragDropEffects.Move);
				}
				catch
				{
					MessageBox.Show("U moet eerst een kleur kiezen voor de bal!");
				}
			}
		}
		//Canvas is de sender
		private void Ellipse_Drop(object sender, DragEventArgs e)
		{
			Ellipse eenBal = new Ellipse();
			eenBal.Fill = (Brush)e.Data.GetData("deKleur");
			KaartCanvas.Children.Add(eenBal);
			Canvas.SetTop(eenBal, e.GetPosition(KaartCanvas).Y - 20);
			Canvas.SetLeft(eenBal, e.GetPosition(KaartCanvas).X - 20);
		}

		private void Nieuw()
		{
			BoodschapBox.Text = "";
			StatusItemName.Content= "";
			KaartCanvas.Children.Clear();
			GrootteLabel.Content = "30";
			MainGrid.Visibility = Visibility.Hidden;
			MenuItemOpslaan.IsEnabled = false;
			//FontFamily moet geen specifieke default hebben vanuit de opgave dus deze laat ik zo.
		}
		private void NewExecuted(object sender, ExecutedRoutedEventArgs e)
		{
			Nieuw();
		}

		private void OpenExecuted(object sender, ExecutedRoutedEventArgs e)
		{
			try
			{
				Nieuw();
				MenuItemOpslaan.IsEnabled = true;
				OpenFileDialog dlg = new OpenFileDialog();
				dlg.Filter = "Kaartvensters | *.krtv";
				if (dlg.ShowDialog() == true)
				{
					using (StreamReader invoer = new StreamReader(dlg.FileName))
					{
						MainGrid.Visibility = Visibility.Visible;

						string pad = invoer.ReadLine(); //first line read
						if (pad == geboorteTag)
						{
							KaartCanvas.Background = (Brush)geboorteAchtergrond;
						}
						else if (pad == kerstTag){
							KaartCanvas.Background = (Brush)kerstAchtergrond;
						}
						else
						{
							throw new Exception("Saved file does not contain a valid background name/path.");
						}
						StatusItemName.Content = dlg.FileName;

						KaartCanvas.Tag = invoer.ReadLine(); //second line read, naam achtergrond
						//Merk op dat ze de "Naam" >nergens< gebruiken dus in essentie je mag het noemen wat je wilt

						//derde read wens
						BoodschapBox.Text = invoer.ReadLine();

						//4de read gebruikte lettertype
						lettertypeComboBox.SelectedItem = new FontFamily(invoer.ReadLine());

						//5de read lettergrootte
						GrootteLabel.Content = invoer.ReadLine();

						//Canvas children
						//Serialization lijkt me hier echt overbodig, het zou hier geheel onnodig de "Make every program a filter" Unix Philosophy regel breken
						string line;
						while (true)
						{
							line = invoer.ReadLine();
							if (line == null)
							{
								break;
							}
							Ellipse bal = new Ellipse();
							bal.Width = 40;
							bal.Height = 40;
							Canvas.SetTop(bal, Convert.ToDouble(line));

							line = invoer.ReadLine();
							if (line == null)
							{
								break;
							}
							Canvas.SetLeft(bal, Convert.ToDouble(line));

							line = invoer.ReadLine();
							if (line == null)
							{
								break;
							}
							bal.Fill = (Brush)new BrushConverter().ConvertFromString(line);
							KaartCanvas.Children.Add(bal);
						}

					}
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show("Openen mislukt: " + ex.Message);
				MainGrid.Visibility = Visibility.Hidden;
			}
		}
		private void SaveExecuted(object sender, ExecutedRoutedEventArgs e)
		{
			try
			{
				SaveFileDialog dlg = new SaveFileDialog();
				dlg.FileName = "";
				dlg.DefaultExt = ".krtv";
				dlg.Filter = "Kaartvensters | *.krtv";
				if (dlg.ShowDialog() == true)
				{

					using (StreamWriter uitvoer = new StreamWriter(dlg.FileName))
					{
						//kaart pad schrijven
						if ((string)KaartCanvas.Tag == kerstTag)
						{
							uitvoer.WriteLine(kerstTag);
						}
						else if ((string)KaartCanvas.Tag == geboorteTag)
						{
							uitvoer.WriteLine(geboorteTag);
						}
						else
						{
							throw new Exception("Saving file shouldn't be possible without valid background name/path.");
						}

						//Kaart naam schrijven, ik noem het gewoon hetzelfde als tag
						//uitvoer.WriteLine(pad.Substring(8, pad.Length - 8));
						uitvoer.WriteLine(KaartCanvas.Tag);

						uitvoer.WriteLine(BoodschapBox.Text);

						uitvoer.WriteLine(Convert.ToString(BoodschapBox.FontFamily));

						uitvoer.WriteLine(GrootteLabel.Content);

						//Canvas children
						Ellipse tempsh = new Ellipse();
						foreach (UIElement child in KaartCanvas.Children)
						{
							if (child.GetType() == tempsh.GetType())
							{
								Ellipse childAlso = (Ellipse)child;
								uitvoer.WriteLine(Convert.ToString(child.GetValue(Canvas.TopProperty)));
								uitvoer.WriteLine(Convert.ToString(child.GetValue(Canvas.LeftProperty)));
								uitvoer.WriteLine(Convert.ToString(childAlso.Fill));
							}
						}
					}
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show("Opslaan mislukt: " + ex.Message);
			}
		}
		
		private void CloseExecuted(object sender, ExecutedRoutedEventArgs e)
		{
			this.Close();
		}
	}
}

