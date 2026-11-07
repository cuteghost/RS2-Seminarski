using System.Globalization;
using System.Net;
using System.Text;

namespace Database.Services.ReportService;

public static class SvgChartBuilder
{
    private const int Width = 800;
    private const int Height = 360;
    private const int MarginLeft = 64;
    private const int MarginRight = 24;
    private const int MarginTop = 48;
    private const int MarginBottom = 64;

    private const string Background = "#FFFFFF";
    private const string Grid = "#E5E7EB";
    private const string Text = "#374151";
    private const string Muted = "#6B7280";
    private const string Primary = "#2563EB";
    private const string Secondary = "#F59E0B";

    public static string LineChart(string title,
                                   IReadOnlyList<string> labels,
                                   IReadOnlyList<(string Name, string Color, IReadOnlyList<double> Values)> series)
    {
        var svg = Begin(title);
        var plotWidth = Width - MarginLeft - MarginRight;
        var plotHeight = Height - MarginTop - MarginBottom;

        var max = series.SelectMany(s => s.Values).DefaultIfEmpty(0).Max();
        var top = NiceMax(max);

        DrawYAxis(svg, top, plotHeight, isCurrency: false);

        var count = labels.Count;
        double X(int i) => MarginLeft + (count <= 1 ? plotWidth / 2.0 : i * plotWidth / (double)(count - 1));
        double Y(double v) => MarginTop + plotHeight - (top == 0 ? 0 : v / top * plotHeight);

        var step = Math.Max(1, (int)Math.Ceiling(count / 12.0));
        for (var i = 0; i < count; i += step)
            svg.Append($"<text x=\"{F(X(i))}\" y=\"{Height - MarginBottom + 20}\" font-size=\"11\" fill=\"{Muted}\" text-anchor=\"middle\">{E(labels[i])}</text>");

        var legendX = MarginLeft;
        foreach (var (name, color, values) in series)
        {
            if (values.Count > 0)
            {
                var points = string.Join(" ", values.Select((v, i) => $"{F(X(i))},{F(Y(v))}"));
                svg.Append($"<polyline points=\"{points}\" fill=\"none\" stroke=\"{color}\" stroke-width=\"2.5\" stroke-linejoin=\"round\"/>");
                for (var i = 0; i < values.Count; i++)
                    svg.Append($"<circle cx=\"{F(X(i))}\" cy=\"{F(Y(values[i]))}\" r=\"3\" fill=\"{color}\"/>");
            }

            svg.Append($"<rect x=\"{legendX}\" y=\"{Height - 22}\" width=\"12\" height=\"12\" rx=\"2\" fill=\"{color}\"/>");
            svg.Append($"<text x=\"{legendX + 18}\" y=\"{Height - 12}\" font-size=\"12\" fill=\"{Text}\">{E(name)}</text>");
            legendX += 24 + name.Length * 7 + 24;
        }

        return End(svg);
    }

    public static string HorizontalBarChart(string title, IReadOnlyList<(string Label, double Value)> bars, string currency)
    {
        var svg = Begin(title);
        if (bars.Count == 0)
        {
            svg.Append($"<text x=\"{Width / 2}\" y=\"{Height / 2}\" font-size=\"14\" fill=\"{Muted}\" text-anchor=\"middle\">No payments in the selected period</text>");
            return End(svg);
        }

        const int labelWidth = 220;
        var plotLeft = labelWidth + 16;
        var plotWidth = Width - plotLeft - 110;
        var plotHeight = Height - MarginTop - 24;
        var rowHeight = plotHeight / (double)bars.Count;
        var barHeight = Math.Min(28, rowHeight * 0.65);
        var max = bars.Max(b => b.Value);
        var top = max <= 0 ? 1 : max;

        for (var i = 0; i < bars.Count; i++)
        {
            var (label, value) = bars[i];
            var y = MarginTop + i * rowHeight + (rowHeight - barHeight) / 2;
            var width = value / top * plotWidth;
            var shortLabel = label.Length > 30 ? label[..29] + "…" : label;

            svg.Append($"<text x=\"{labelWidth}\" y=\"{F(y + barHeight / 2 + 4)}\" font-size=\"12\" fill=\"{Text}\" text-anchor=\"end\">{E(shortLabel)}</text>");
            svg.Append($"<rect x=\"{plotLeft}\" y=\"{F(y)}\" width=\"{F(Math.Max(1, width))}\" height=\"{F(barHeight)}\" rx=\"3\" fill=\"{(i == 0 ? Secondary : Primary)}\"/>");
            svg.Append($"<text x=\"{F(plotLeft + width + 6)}\" y=\"{F(y + barHeight / 2 + 4)}\" font-size=\"12\" fill=\"{Text}\">{E(Money(value, currency))}</text>");
        }

        return End(svg);
    }

    private static StringBuilder Begin(string title)
    {
        var svg = new StringBuilder();
        svg.Append($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{Width}\" height=\"{Height}\" viewBox=\"0 0 {Width} {Height}\" font-family=\"Helvetica, Arial, sans-serif\">");
        svg.Append($"<rect width=\"{Width}\" height=\"{Height}\" fill=\"{Background}\"/>");
        svg.Append($"<text x=\"{MarginLeft}\" y=\"28\" font-size=\"16\" font-weight=\"bold\" fill=\"{Text}\">{E(title)}</text>");
        return svg;
    }

    private static string End(StringBuilder svg)
    {
        svg.Append("</svg>");
        return svg.ToString();
    }

    private static void DrawYAxis(StringBuilder svg, double top, int plotHeight, bool isCurrency)
    {
        const int ticks = 5;
        for (var t = 0; t <= ticks; t++)
        {
            var value = top * t / ticks;
            var y = MarginTop + plotHeight - (double)t / ticks * plotHeight;
            svg.Append($"<line x1=\"{MarginLeft}\" y1=\"{F(y)}\" x2=\"{Width - MarginRight}\" y2=\"{F(y)}\" stroke=\"{Grid}\" stroke-width=\"1\"/>");
            svg.Append($"<text x=\"{MarginLeft - 8}\" y=\"{F(y + 4)}\" font-size=\"11\" fill=\"{Muted}\" text-anchor=\"end\">{E(value.ToString(isCurrency ? "N0" : "0.#", CultureInfo.InvariantCulture))}</text>");
        }
    }

    private static double NiceMax(double max)
    {
        if (max <= 0)
            return 1;

        var magnitude = Math.Pow(10, Math.Floor(Math.Log10(max)));
        var normalized = max / magnitude;
        var nice = normalized <= 1 ? 1 : normalized <= 2 ? 2 : normalized <= 5 ? 5 : 10;
        return nice * magnitude;
    }

    private static string Money(double value, string currency) =>
        $"{value.ToString("N2", CultureInfo.InvariantCulture)} {currency}";

    private static string F(double value) => value.ToString("0.##", CultureInfo.InvariantCulture);

    private static string E(string value) => WebUtility.HtmlEncode(value);
}
