class TextsController < ApplicationController
  before_action :set_text, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!


  # GET /texts
  # GET /texts.json
  def index
=begin
    @limit = params[:limit]
    offset = params[:offset].to_i

    @limit ||= 50
    offset ||= 0
    @limit = @limit.to_i
    @next = @limit + offset

    num_texts = Text.count
    remaining_texts = num_texts - @next

    if remaining_texts < 0
      @next = nil
    end

    if offset > (@limit - 1)
      @prev = offset - @limit
    elsif offset > 0
      @prev = 0
    else
      @prev = nil
    end

    texts = Text.limit(@limit).offset(offset)
    @authors = []
    author_group = {
        :author => texts[0].topic_author.full_name,
        :texts => []
    }

    texts.each do |text|
      unless text.topic_author.full_name == author_group[:author]
        @authors.push(author_group)
        author_group = {
            :author => text.topic_author.full_name,
            :texts => []
        }
      end
      author_group[:texts].push(text)
    end
    @authors.push(author_group)
=end

    @texts = Text.order(:census_id).page(params[:page])
  end

  # GET /texts/1
  # GET /texts/1.json
  def show
  end

  # GET /texts/new
  def new
    @text = Text.new
  end

  # GET /texts/1/edit
  def edit
  end

  # POST /texts
  # POST /texts.json
  def create
    @text = Text.new(text_params)

    respond_to do |format|
      if @text.save
        format.html {redirect_to @text, notice: 'Text was successfully created.'}
        format.json {render :show, status: :created, location: @text}
      else
        format.html {render :new}
        format.json {render json: @text.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /texts/1
  # PATCH/PUT /texts/1.json
  def update
    respond_to do |format|
      if @text.update(text_params)
        format.html {redirect_to @text, notice: 'Text was successfully updated.'}
        format.json {render :show, status: :ok, location: @text}
      else
        format.html {render :edit}
        format.json {render json: @text.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /texts/1
  # DELETE /texts/1.json
  def destroy
    @text.destroy
    respond_to do |format|
      format.html {redirect_to texts_url, notice: 'Text was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_text
    @text = Text.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def text_params
    params.require(:text).permit(:title, :source, :date, :publisher, :location, :note, :original, :census_id,
                                 :parent_title, :parent_issue,
                                 text_citations_attributes: [:id, :role, :name, :_destroy],
                                 standard_numbers_attributes: [:id, :value, :_destroy],
                                 components_attributes: [:id, :title, :pages, :_destroy]
    )
  end
end
