# app/helpers/posts_helper.rb
module PostsHelper
  def sort_link(label, key)
    current_sort  = params[:sort].presence || "published"
    current_order = params[:order].presence || "desc"
    next_order    = (current_sort == key && current_order == "desc") ? "asc" : "desc"

    arrow =
      if current_sort == key
        current_order == "desc" ? "⬇︎" : "⬆︎"
      else
        "⇅"
      end

    link_to "#{label} #{arrow}".html_safe,
      posts_path(params.permit!.to_h.merge(sort: key, order: next_order)),
      class: "inline-flex items-center gap-1 text-slate-700 hover:text-blue-700 font-medium"
  end

  def published_badge(post)
    if post.published_at.present?
      content_tag :span, "Pubblicato · #{I18n.l(post.published_at, format: :short)}",
                  class: "inline-flex items-center rounded-full bg-emerald-50 text-emerald-700 px-2 py-0.5 ring-1 ring-emerald-200 text-xs font-semibold"
    else
      content_tag :span, "Bozza",
                  class: "inline-flex items-center rounded-full bg-amber-50 text-amber-700 px-2 py-0.5 ring-1 ring-amber-200 text-xs font-semibold"
    end
  end
end
