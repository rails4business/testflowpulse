module MenuHelper
  # unica fonte di verità
  def main_menu_items
    [
      { label: "🏠 Home",       path: dashboard_home_path },
      { label: "📊 Post",       path: posts_path },
      { label: "🧑‍💼 Superadmin", path: dashboard_superadmin_path, if: -> { Current.user&.superadmin? } }


    ]
  end

  # attivo semplice (adatta se usi params o named routes diversi)
  def nav_active?(path)
    request.path == path
  end

  # classi base per link
  def nav_link_classes(active)
    base = "flex items-center p-2 rounded-lg text-sm transition whitespace-nowrap"
    active ? "#{base} bg-gray-100 text-gray-900 dark:bg-gray-700 dark:text-white font-semibold"
           : "#{base} text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700"
  end
end
