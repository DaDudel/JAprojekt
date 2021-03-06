//Maciej Duda gr 2 AEI sem 5
//JA Projekt - filtr usredniajacy z histogramem
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dllCS
{
    public class Class1
    {
        //filtrowanie tablicy i zapisanie wyniku w drugiej tablicy
        public void filtruj(byte[] t, int aw, int ah, byte[] afin)
        {
            for (int y = 1; y < ah - 1; y++)
            {
                for (int x = 3; x < aw * 3 - 3; x += 3)
                {
                    int R = 0;
                    int G = 0;
                    int B = 0;
                    //sumowanie wartosci RGB
                    for (int pxY = -1; pxY <= 1; pxY++)
                    {
                        for (int pxX = -1; pxX <= 1; pxX++)
                        {
                            R = R + t[(y - pxY) * aw * 3 + x + pxX * 3];
                            G = G + t[(y - pxY) * aw * 3 + x + pxX * 3 + 1];
                            B = B + t[(y - pxY) * aw * 3 + x + pxX * 3 + 2];
                        }
                    }
                    //usrednianie wartosci
                    R = R / 9;
                    G = G / 9;
                    B = B / 9;

                    //zapisanie wartosci w drugiej tablicy
                    afin[y * aw * 3 + x + 0] = (byte)R;
                    afin[y * aw * 3 + x + 1] = (byte)G;
                    afin[y * aw * 3 + x + 2] = (byte)B;
                }
            }
            return;
        }
    }
}
