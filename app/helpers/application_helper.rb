module ApplicationHelper
  def safe_svg(svg_string)
    sanitize(svg_string, 
      tags: %w[svg path rect circle polygon polyline ellipse g defs use mask pattern clipPath text tspan desc title], 
      attributes: %w[xmlns viewBox width height fill stroke stroke-width stroke-linecap stroke-linejoin d cx cy r x y rx ry points id class opacity fill-rule clip-rule clip-path transform font-size text-anchor dominant-baseline]
    )
  end
end
