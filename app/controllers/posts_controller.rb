
require "reverse_markdown"

class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :set_posts
  before_action :set_superadmin

   # GET /posts or /posts.json
   def index
    @params = params.permit(:scope, :sort, :order, :q, :preset, :date)

    # mappa preset -> mode
    mode =
      if @params[:date].present?
        "custom"
      else
        case @params[:preset]
        when "year"   then "year"
        when "last7"  then "last7"
        when "last30" then "last30"
        else nil # nessun filtro data di default
        end
      end

    @posts = Post.all
    @posts = @posts.scoped_by(@params[:scope])
    @posts = @posts.search(@params[:q])

    # applica filtro data solo se mode è presente
    if mode.present?
      @posts = @posts.date_filtered(
        mode:  mode,
        date:  @params[:date],
        sort:  @params[:sort],
        order: @params[:order]
      )
    end

    @posts = @posts.ordered_by(@params[:sort], @params[:order]).includes(:user)
  end


  # GET /posts/1 or /posts/1.json
  def show
    end


  # GET /posts/new
  def new
    @post = Current.user.posts.build
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = Current.user.posts.build(post_params)

    if @post.save
      flash[:alert] = "Attenzione: esiste già un altro post con questo titolo." if @post.duplicate_title?
      respond_to do |format|
        format.html { redirect_to @post, notice: "Post creato con successo." }
        format.json { render :show, status: :created, location: @post }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/:slug



  def update
    if @post.update(post_params)
      flash[:alert] = "Attenzione: esiste già un altro post con questo titolo." if @post.duplicate_title?
      respond_to do |format|
        format.html { redirect_to @post, notice: "Aggiornato con successo." }
        format.json { render :show, status: :ok, location: @post }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end



  # Se usi gli slug nelle rotte: resources :posts, param: :slug




  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def export
    posts = @post.present? ? [ @post ] : Post.order(:sort_published_or_created)

    respond_to do |format|
      format.json do
        render json: posts.map { |p|
          {
            id: p.id,
            slug: p.slug,
            title: p.title,
            description: p.description,
            img_square_url: p.img_square_url,
            img_vertical_url: p.img_vertical_url,
            img_orizontal_url: p.img_orizontal_url,
            published_at: p.published_at,
            meta: p.meta,
            body_html: p.body_html # ActionText HTML
          }
        }
      end


      format.csv do
        csv = CSV.generate(headers: true) do |out|
          out << %w[id slug title description published_at]
          posts.each { |p| out << [ p.id, p.slug, p.title, p.description, p.published_at ] }
        end



        send_data csv,
         filename: (@post ? "post-#{@post.slug}-#{Time.now.strftime('%Y%m%d')}.csv" : "posts.csv"),
          type: "text/csv; charset=utf-8",
          disposition: "attachment"
      end

      # Facoltativo: singolo in Markdown con front-matter (HTML nel body)
      format.md do
        raise ActionController::RoutingError, "Not Found" unless @post

        # 🔹 Converte l'HTML di Lexxy/ActionText in Markdown leggibile
        md_body = ReverseMarkdown.convert(@post.body_html.to_s)

        md = <<~MD
        ---
        slug: #{@post.slug}
        title: #{@post.title&.to_s&.gsub("---", "—")}
        description: #{@post.description&.to_s&.gsub("---", "—")}
        published_at: #{@post.published_at}
        img_square_url: #{@post.img_square_url}
        img_vertical_url: #{@post.img_vertical_url}
        img_orizontal_url: #{@post.img_orizontal_url}
        meta: #{@post.meta.to_json}
        ---

        #{md_body}
        MD

        send_data md, filename: "post-#{@post.slug}.md"
      end
    end
  end

  # ===== IMPORT =====
  # POST /posts/import (params[:file] JSON o CSV)
  def import
    file = params[:file] || params.dig(:import, :file)
    unless file
      Rails.logger.warn("[Posts#import] Nessun file nei params: #{params.to_unsafe_h.keys.inspect}")
      return redirect_to posts_path, alert: "Nessun file caricato."
    end


    imported = 0
    errors   = []

    if File.extname(file.original_filename).downcase == ".csv"
      csv = CSV.parse(file.read, headers: true)
      csv.each do |row|
        begin
          upsert_post!(
            slug: row["slug"],
            title: row["title"],
            description: row["description"],
            img_square_url: row["img_square_url"],
            img_vertical_url: row["img_vertical_url"],
            img_orizontal_url: row["img_orizontal_url"],
            published_at: row["published_at"],
            meta: safe_json(row["meta"]),
            body_html: row["body_html"]
          )
          imported += 1
        rescue => e
          errors << "#{row["slug"] || row["title"]}: #{e.message}"
        end
      end
    else
      # JSON array di post
      payload = JSON.parse(file.read)
      payload.each do |h|
        begin
          upsert_post!(
            slug: h["slug"],
            title: h["title"],
            description: h["description"],
            img_square_url: h["img_square_url"],
            img_vertical_url: h["img_vertical_url"],
            img_orizontal_url: h["img_orizontal_url"],
            published_at: h["published_at"],
            meta: h["meta"],
            body_html: h["body_html"] # HTML ActionText
          )
          imported += 1
        rescue => e
          errors << "#{h["slug"] || h["title"]}: #{e.message}"
        end
      end
    end

    msg = "Importati #{imported} post."
    msg += " Errori: #{errors.size}" if errors.any?
    redirect_to posts_path, notice: msg, alert: (errors.any? ? errors.join(" | ") : nil)
  end

  private



  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Current.user.posts.find(params.expect(:id))
  end
  def set_superadmin
    unless Current.user&.superadmin?
      redirect_to dashboard_home_path
    end
  end
  def set_posts
     @posts = Current.user.posts.select(:id, :title, :slug, :published_at, :created_at, :updated_at, :img_square_url)
  end
  # Only allow a list of trusted parameters through.
  def post_params
    params.expect(post: [ :user_id, :title, :slug, :description, :img_square_url, :img_vertical_url, :img_orizontal_url, :body, :published_at, :group_id, :group_type, :meta ])
  end
  # Trova per slug o crea; assegna body (HTML); salva!
  def upsert_post!(slug:, title:, description:, img_square_url:, img_vertical_url:, img_orizontal_url:, published_at:, meta:, body_html:)
    raise "slug mancante" if slug.blank?
    post = Post.find_or_initialize_by(slug: slug)
    post.user ||= current_user if respond_to?(:current_user) && current_user
    post.assign_attributes(
      title:,
      description:,
      img_square_url:,
      img_vertical_url:,
      img_orizontal_url:,
      published_at: (published_at.presence && Time.zone.parse(published_at)) # safe parse
    )
    post.meta = meta if meta.present?
    # Import del body: HTML diretto in ActionText
    post.body = body_html.to_s if body_html.present?
    post.save!
  end

  def safe_json(val)
    return if val.blank?
    return val if val.is_a?(Hash)
    JSON.parse(val) rescue {}
  end
end
