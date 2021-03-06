//Maciej Duda gr 2 AEI sem 5
//JA Projekt - filtr usredniajacy z histogramem
using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using LiveCharts;
using LiveCharts.Wpf;
using System.Reflection;
using System.Threading;

namespace JAprojekt
{
    /// <summary>
    /// Logika interakcji dla klasy MainWindow.xaml
    /// </summary>
    delegate void filtruj_delegate(byte[] t, int aw, int ah, byte[] afin);
    public partial class MainWindow : Window
    {
        public SeriesCollection SeriesCollection { get; set; }
        public SeriesCollection SeriesCollectionAfter { get; set; }

        Bitmap bmp;
        Bitmap bmpFin;

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr LoadLibrary(string libname);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        private static extern bool FreeLibrary(IntPtr hModule);
        [DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

        bool isFileGood = false;
        bool isPhotoGenerated = false;

        filtruj_delegate filter; //wskaźnik na funckję wykonywującą algorytm

        public MainWindow()
        {
            //inicjalizacja
            InitializeComponent();
            InitHistogram();
        }

        //Ładuje biblioteke asm
        void LoadFromAsm(byte[] t, int aw, int ah, byte[] afin)
        {
            IntPtr Handle = LoadLibrary(@"./dllASM.dll");
            IntPtr funcaddr = GetProcAddress(Handle, "filtr");
            filtruj_delegate function = Marshal.GetDelegateForFunctionPointer(funcaddr, typeof(filtruj_delegate)) as filtruj_delegate;
            function.Invoke(t, aw, ah, afin);
        }

        //Ładuje biblioteke cs
        void LoadFromCs(byte[] t, int aw, int ah, byte[] afin)
        {
            var dllFile = new FileInfo(@"./dllCS.dll");
            var DLL = Assembly.LoadFile(dllFile.FullName);
            var class1Type = DLL.GetType("dllCS.Class1");
            dynamic c = Activator.CreateInstance(class1Type);
            c.filtruj(t, aw, ah, afin);
        }

        //wczytanie obrazka i zapisanie go jako bitmapa
        private void Button_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog op = new OpenFileDialog();
            if(op.ShowDialog()==true)
            {
                var plik = op.FileName;
                Uri uri = new Uri(plik);
                bmp = new Bitmap(plik);
                if(bmp.Width*bmp.Height < 60000000)
                {
                    Source_Image.Source = new BitmapImage(uri);
                    isFileGood = true;
                    isPhotoGenerated = false;
                }
                else
                {
                    MessageBox.Show("Zdjęcie jest zbyt duże");
                }
            }
        }

        private void RadioButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void RadioButton_Click_1(object sender, RoutedEventArgs e)
        {

        }

        [DllImport("gdi32.dll", EntryPoint = "DeleteObject")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool DeleteObject([In] IntPtr hObject);
        public ImageSource Sos(Bitmap b)
        {
            var h = b.GetHbitmap();
            try
            {
                return Imaging.CreateBitmapSourceFromHBitmap(h, IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
            }
            finally { DeleteObject(h); }
        }
        //rozpoczecie filtrowania, wykonuje sie po wcisnieciu guzika filtruj
        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            if (isFileGood == false)
            {
                MessageBox.Show("Nie udało się wygenerować zdjęcia");
                return;
            }
            //wybor biblioteki
            if (CSButton.IsChecked == true)
                filter = LoadFromCs;
            else
                filter = LoadFromAsm;
            //inicjalizacja timera
            var timer = System.Diagnostics.Stopwatch.StartNew();

            Bitmap bmpfin = new Bitmap(bmp);
            int x, y;
            

            int h = bmp.Height;
            int w = bmp.Width;

            System.Drawing.Rectangle rect = new System.Drawing.Rectangle(0, 0, bmp.Width, bmp.Height);
            bmpFin = bmp.Clone(rect, System.Drawing.Imaging.PixelFormat.Format24bppRgb);

            System.Drawing.Imaging.BitmapData bmpData =
                bmpFin.LockBits(rect, System.Drawing.Imaging.ImageLockMode.ReadWrite,
                bmpFin.PixelFormat);

            IntPtr ptr = bmpData.Scan0;
            int offset = Math.Abs(bmpData.Stride) - (bmpFin.Width * 3);
            int bytes = bmpData.Width * 3 * bmpFin.Height;

            //tabele przechowujace dane obrazu
            byte[] rgbValues = new byte[bytes];
            byte[] rgbValuesFin = new byte[bytes];

            

            int pos = 0;
            for (int i = 0; i < bmpFin.Height * Math.Abs(bmpData.Stride); i += bmpFin.Width * 3)
            {
                System.Runtime.InteropServices.Marshal.Copy(ptr + i, rgbValues, pos, bmpFin.Width * 3);
                pos += bmpFin.Width * 3;
                i += offset;
            }

            pos = 0;
            for (int i = 0; i < bmpFin.Height * Math.Abs(bmpData.Stride); i += bmpFin.Width * 3)
            {
                System.Runtime.InteropServices.Marshal.Copy(ptr + i, rgbValuesFin, pos, bmpFin.Width * 3);
                pos += bmpFin.Width * 3;
                i += offset;
            }

            //tworzenie histogramu oryginalnego obrazu
            createHist(rgbValues, SeriesCollection);

            //filtrowanie
            int tnumber = (int)threadnumber.Value;
            multiThreads(tnumber, rgbValues, w, h, rgbValuesFin);
            

            pos = 0;
            for (int i = 0; i < bmpFin.Height * Math.Abs(bmpData.Stride); i += bmpFin.Width * 3)
            {
                System.Runtime.InteropServices.Marshal.Copy(rgbValuesFin, pos, ptr + i, bmpFin.Width * 3);
                pos += bmpFin.Width * 3;
                i += offset;
            }

            bmpFin.UnlockBits(bmpData);

            
            //zatrzymanie timera
            timer.Stop();
            var elapsedMs = timer.ElapsedMilliseconds;
            czas.Content = elapsedMs.ToString();

            //histogram przefiltrowanego obrazu
            createHist(rgbValuesFin, SeriesCollectionAfter);

            Final_Image.Source = Sos(bmpFin);

            isPhotoGenerated = true;
        }
        //wielowątkowość
        private void multiThreads(int threads,byte[] rgbValues, int w, int h, byte[] rgbValuesAfter)
        {
            if (threads > h)
            {
                threads = (int)(h/3);
            }
            int mh = h % threads;
            int helph = (int)(h / threads);
            byte[][] threadArrays = new byte[threads][];
            byte[][] threadArraysAfter = new byte[threads][];
            List<Thread> threadList = new List<Thread>();
            List<fData> dataList = new List<fData>();
            int hpos = 0;

            //dzielenie obrazu na mniejsze
            for(int y = 0; y<(h-mh-1);y=y+helph)
            {
                int istart = y;
                int iend = y + helph;
                if(mh > 0)
                {
                    iend++;
                    mh--;
                    y++;
                }
                if(istart>0)
                {
                    istart--;
                }
                if(iend<h)
                {
                    iend++;
                }
                threadArrays[hpos] = new byte[iend * w * 3 - (istart * w * 3)];
                int tpos = hpos;
                Array.Copy(rgbValues, istart * w * 3, threadArrays[tpos], 0, iend * w * 3 - (istart * w * 3));
                threadArraysAfter[tpos] = new byte[iend * w * 3 - (istart * w * 3)];
                fData data = new fData(threadArrays[tpos], w, iend - istart, threadArraysAfter[tpos], filter);

                Thread t = new Thread(data.filter);
                threadList.Add(t);
                dataList.Add(data);

                hpos++;
            }

            int tcount = 0;
            threadList.ForEach(t =>
            {
                t.IsBackground = true;
                t.Start(dataList[tcount]);
                tcount++;
            });

            //laczenie mniejszych przefiltrowanych obrazow w calosc
            int ch = 0;
            int helphsum = 0;
            for(int i = 0; i<threads;i++)
            {
                threadList[i].Join();
                byte[] himage = threadArraysAfter[i];
                helphsum = helphsum + (himage.Length / (w * 3));
                if(i==0)
                {
                    Array.Copy(himage, 0, rgbValuesAfter, ch, himage.Length - (w * 3));
                    ch = ch + (himage.Length / (w * 3) - 1);
                }
                else
                {
                    Array.Copy(himage, w*3, rgbValuesAfter, ch*w*3, himage.Length - (w * 3));
                    ch = ch + (himage.Length / (w * 3) - 2);
                }
            }
            threadList.Clear();
        }
        //fragment obrazu do przefiltrowania
        class fData
        {
            private byte[] arrayBefore;
            private int w;
            private int h;
            private byte[] arrayAfter;
            private filtruj_delegate delegat;
            
            public fData(byte[] arrayBefore,int w,int h, byte[] arrayAfter, filtruj_delegate lib)
            {
                this.arrayBefore = arrayBefore;
                this.w = w;
                this.h = h;
                this.arrayAfter = arrayAfter;
                this.delegat = lib;
            }
            public void filter(object data)
            {
                delegat.Invoke(arrayBefore, w, h, arrayAfter);
            }
        }
        //zapis do pliku
        private void Button_Click_2(object sender, RoutedEventArgs e)
        {
            if(isFileGood==false)
            {
                MessageBox.Show("Nie udało się zapisać zdjęcia");
                return;
            }
            if(!isPhotoGenerated || Final_Image == null)
            {
                MessageBox.Show("Nie udało się zapisać zdjęcia");
                return;
            }
            SaveFileDialog saveFileDialog = new SaveFileDialog();
            saveFileDialog.Filter = "JPG (*.jpg)|*.jpg|PNG (*.png)|*.png";
            if (saveFileDialog.ShowDialog() == true)
            {
                var fileName = saveFileDialog.FileName;
                var extension = System.IO.Path.GetExtension(saveFileDialog.FileName);

                switch (extension.ToLower())
                {
                    case ".jpg":
                        bmpFin.Save(fileName, System.Drawing.Imaging.ImageFormat.Jpeg);
                        break;
                    case ".png":
                        bmpFin.Save(fileName, System.Drawing.Imaging.ImageFormat.Png);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException(extension);
                }
            }
        }
        //tworzenie histogramu
        private void createHist (byte[] rgbValues, SeriesCollection series)
        {
            int[] R = new int[256];
            int[] G = new int[256];
            int[] B = new int[256];

            series[0].Values.Clear();
            series[1].Values.Clear();
            series[2].Values.Clear();

            for (int i = 0; i < 256; i++)
            {
                R[i] = 0;
                G[i] = 0;
                B[i] = 0;
            }

            for(int i = 0; i < rgbValues.Length-3; i += 3)
            {
                R[(int)rgbValues[i]]++;
                G[(int)rgbValues[i + 1]]++;
                B[(int)rgbValues[i + 2]]++;
            }

            for (int i = 0; i < 256; i++)
            {
                series[0].Values.Add(R[i]);
                series[1].Values.Add(G[i]);
                series[2].Values.Add(B[i]);
            }
        }
        //inicjalizacja histogramu
        private void InitHistogram()
        {
            chart.AxisY.Clear();
            chart.AxisY.Add(
                new Axis
                {
                    MinValue = 0
                }
            );

            chartAfter.AxisY.Clear();
            chartAfter.AxisY.Add(
                new Axis
                {
                    MinValue = 0
                }
            );

            SeriesCollection = new SeriesCollection
            {
                new LineSeries
                {
                    Title = "Red",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Red
                },
                new LineSeries
                {
                    Title = "Green",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Green
                },
                new LineSeries
                {
                    Title = "Blue",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Blue
                }
            };

            SeriesCollectionAfter = new SeriesCollection
            {
                new LineSeries
                {
                    Title = "Red",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Red
                },
                new LineSeries
                {
                    Title = "Green",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Green
                },
                new LineSeries
                {
                    Title = "Blue",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Blue
                }
            };


            DataContext = this;
        }
    
}
}
