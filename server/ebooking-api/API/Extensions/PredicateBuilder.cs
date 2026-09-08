using System.Linq.Expressions;

namespace API.Extensions;

/// <summary>
/// Spajanje dva uslova u jedan izraz, tako da oba i dalje idu u SQL.
///
/// <para>
/// Obično <c>a =&gt; left(a) &amp;&amp; right(a)</c> se ne može napisati nad dvije gotove lambde jer
/// svaka ima svoj parametar; EF onda ne zna da su to isti <c>a</c>. Zato se tijelo desnog izraza
/// ponovo veže za parametar lijevog.
/// </para>
/// </summary>
public static class PredicateBuilder
{
    public static Expression<Func<T, bool>> And<T>(this Expression<Func<T, bool>> left,
                                                   Expression<Func<T, bool>> right)
    {
        var parameter = Expression.Parameter(typeof(T), "entity");

        var body = Expression.AndAlso(
            new ParameterRebinder(left.Parameters[0], parameter).Visit(left.Body),
            new ParameterRebinder(right.Parameters[0], parameter).Visit(right.Body));

        return Expression.Lambda<Func<T, bool>>(body, parameter);
    }

    private sealed class ParameterRebinder : ExpressionVisitor
    {
        private readonly ParameterExpression _from;
        private readonly ParameterExpression _to;

        public ParameterRebinder(ParameterExpression from, ParameterExpression to)
        {
            _from = from;
            _to = to;
        }

        protected override Expression VisitParameter(ParameterExpression node) =>
            node == _from ? _to : base.VisitParameter(node);
    }
}
